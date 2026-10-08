# Exercises the token classes the Mapping colours for Terraform (HCL): block
# keywords, nested block types, attributes, functions, strings with
# interpolation, numbers, booleans, null, operators, brackets and comments.

terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

variable "region" {
  type        = string
  description = "Region to deploy into"
  default     = "us-west-2"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "replicas" {
  type    = number
  default = 3

  validation {
    condition     = var.replicas > 0 && var.replicas <= 10
    error_message = "replicas must be between 1 and 10."
  }
}

locals {
  name      = "${var.region}-queue"
  banner    = "ready\tfor ${var.region}\n"
  is_prod   = terraform.workspace == "prod"
  cidr      = cidrsubnet("10.0.0.0/16", 8, 1)
  all_tags  = merge(var.tags, { Name = local.name, Env = terraform.workspace })
  ports     = [for p in [80, 443, 8080] : p if p != 8080]
  user_data = <<-EOT
    #!/bin/sh
    echo "hello ${local.name}"
  EOT
}

data "aws_ami" "base" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*"]
  }
}

resource "aws_instance" "queue" {
  count = local.is_prod ? var.replicas : 1

  ami           = data.aws_ami.base.id
  instance_type = local.is_prod ? "m6i.large" : "t3.micro"
  user_data     = local.user_data
  tags          = local.all_tags

  // Nested blocks read in the type colour.
  root_block_device {
    volume_size = 20
    encrypted   = true
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [ami]
  }
}

/* A dynamic block with for_each. */
resource "aws_security_group" "queue" {
  name = format("%s-sg", local.name)

  dynamic "ingress" {
    for_each = toset(local.ports)
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = [local.cidr]
    }
  }
}

module "dns" {
  source  = "./modules/dns"
  zone    = null
  path    = path.module
  targets = aws_instance.queue[*].private_ip
}

output "instance_ids" {
  value     = aws_instance.queue[*].id
  sensitive = false
}
