# One command regenerates the Palette files and the Theme Family and runs the tests.
# Any failing step stops make with a non-zero exit.
NVIM ?= nvim

.PHONY: all extract build test

all: extract build test

extract:
	$(NVIM) --clean -l scripts/extract.lua

build:
	$(NVIM) --clean -l scripts/build.lua

test:
	$(NVIM) --clean -l tests/run.lua
