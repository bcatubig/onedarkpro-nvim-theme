# Sign-off checklist

The visual criterion that closes spec #1: the same six files, open side by side in nvim and in Zed, show the same colours, both Variants, apart from the Deviations and Query Differences listed here. Anything else that differs is a finding: file an issue naming the sample line and the Syntax Key or Style Key.

Expected colours are given as Palette colour names; the hex values for both Variants are in the [Palette reference](#palette-reference) at the end. An expectation holds for both Variants unless it says otherwise.

## Setup

**nvim.** Upstream should be at the commit the submodule pins (`git -C upstream rev-parse --short HEAD`; your lazy-lock pins the same one). Then, in the sample's buffer:

- `:colorscheme onedark` for the dark pass, `:colorscheme onelight` for the light pass.
- `:set conceallevel=0`, so Markdown delimiters, link brackets and fences are visible for comparison.
- `:RenderMarkdown disable` in `sample.md`. render-markdown.nvim replaces list markers with icons in its own colour and adds backgrounds.
- Stop LSP semantic tokens, which recolour identifiers on top of treesitter (gopls has them on):
  `:lua for _, c in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do vim.lsp.semantic_tokens.stop(0, c.id) end`
- Open `sample.yml` as plain `yaml`. Your filetype patterns send `*playbook*`, `tasks/`, `handlers/` and `group_vars/` to `yaml.ansible`; `samples/sample.yml` matches none of them. If it does on your machine, `:set ft=yaml`.

**Zed.** Open the repository (or `samples/`) as the project.

- Dark pass: `theme.mode` `"dark"` (or `"system"` with macOS in dark appearance). Light pass: `"light"`. Settings changes apply live; only a rebuilt Theme needs a Zed restart.
- Open `sample.yml` as YAML, not Ansible. Your `file_types` send `*playbook*.yml`, `**/tasks/*.yml` and friends to the Ansible extension, which injects Jinja into `{{ }}` and recolours it; `samples/sample.yml` matches none of them.
- For the Chrome checks: `"show_whitespaces": "all"`, `"inlay_hints": { "enabled": true }`, vim mode on (it is), and a second pane (`pane: split right`).

**Reading the tables.** Each row is a token class the Mapping colours: what to look at in the sample, the expected colour, and the Zed Syntax Key and nvim group behind it. "Deviation n" points at the numbered list in the README and in the header of `scripts/mapping.lua`. "Query Difference" marks a token Zed's query captures under a different name from nvim-treesitter's, or not at all, so the Mapping cannot reach it; expect the two colours given.

The expectations below were derived by rendering each sample twice under headless nvim: once with Upstream and the nvim-treesitter queries installed on this machine (nvim-treesitter `main` at f603a2f, the queries your `:TSInstall` placed in `site/queries`), and once with Zed 1.23.2's own highlight queries (built-in Go, Python, Bash, YAML and Markdown; the Terraform extension's) resolved through the built Theme by Zed's rules. Your eyes are the final check; the derivation only says where to look.

---

## Go: `samples/sample.go`

Spec stories 5, 6, 7.

| Token class | In the sample | Expected | Zed Syntax Key | nvim group |
| --- | --- | --- | --- | --- |
| Keywords | `package`, `import`, `type`, `func`, `const`, `var`, `for`, `range`, `if`, `return`, `go`, `defer`, `switch`, `case`, `default`, `break`, `struct`, `interface` | purple | `keyword`, `keyword.control` | Keyword, `@keyword.*` |
| `chan`, `map` | `chan<- int`, `make(chan int)`, `make(map[int]bool)` | purple; the two agree only because nvim-treesitter names them `@type.builtin` and the Go Filetype Override colours that purple (Deviation 2's nvim side) | `keyword` | `@type.builtin.go` |
| Functions and methods | `NewQueue`, `Push`, `describe`, `drain`, `run`; calls `errors.New`, `fmt.Errorf`, `sb.WriteString` | blue | `function`, `function.method` | `@function`, `@function.method` |
| Builtin functions | `make`, `len`, `append`, `close` | cyan | `function.builtin` | `@function.builtin.go` |
| Types | `State`, `Queue`, `Sizer`, `strings.Builder`, `T` | yellow | `type` | `@type` |
| Builtin types | `int`, `string`, `float64`, `bool`, `error`, `any` | **Deviation 2**: yellow in Zed, purple in nvim | `type.builtin` | `@type.builtin.go` |
| Constants | `Idle`, `Running`, `Stopped`, `MaxRetries` | **Deviation 3**: orange in Zed, red in nvim | `constant` | `@constant.go` |
| `iota`, `nil` | lines 20, 56 | purple | `constant.builtin` | `@constant.builtin` |
| Numbers and booleans | `3`, `0`, `0.5`, `0x7f`, `1e3`, `2`, `true` | orange | `number`, `boolean` | Number, Boolean |
| Strings | `"queue closed"`, `"%s: %w (limit %d)"`, the raw string, the rune `'x'` | green | `string` | `@string`, Character |
| Escapes | `\n`, `\t` in `"idle\n"`, `"busy\t"` | cyan | `string.escape` | `@string.escape` |
| Variables and parameters | `q`, `item`, `sb`, `s`, `ratio`, `ok`, `i`, `v`, `out` | red | `variable` | `@variable`, `@variable.parameter` |
| Fields and properties | `items`, `limit`, `name` in the struct and after `q.` | red | `property` | `@variable.member`, `@property` |
| Package names | `errors`, `fmt`, `strings` | yellow | `namespace` | `@module` |
| Labels | `outer:`, `break outer` | purple | `label` | `@label` |
| Operators | `:=`, `>=`, `&&`, `\|\|`, `<-`, `*`, `==`, `!=`, `>` | cyan | `operator` | `@operator` |
| Brackets | `(` `)` `{` `}` `[` `]` | purple | `punctuation.bracket` | `@punctuation.bracket` |
| Delimiters | `.`, `,`, `:` | fg | `punctuation.delimiter` | Delimiter |
| Comments | every `//` line | comment | `comment` | Comment |
| Directives | `//go:build …`, `//go:generate …` | comment, like a plain comment | `preproc` | `@comment` |

Deviations: 2 and 3. Query Differences: none found in this sample.

---

## Python: `samples/sample.py`

Spec stories 8, 9.

| Token class | In the sample | Expected | Zed Syntax Key | nvim group |
| --- | --- | --- | --- | --- |
| Keywords | `def`, `class`, `return`, `if`, `else`, `for`, `in`, `is`, `not`, `or`, `try`, `except`, `raise`, `from`, `import`, `with`, `as`, `match`, `case`, `lambda` | purple | `keyword`, `keyword.operator`, `keyword.definition` | `@keyword.*` |
| Decorators | `@dataclass`, `@property`, `@classmethod`, `@functools.wraps(fn)`, `@retry(times=2)` | blue, the whole decorator, in Zed. nvim: the `@` blue; `property`, `classmethod`, `wraps` blue; `dataclass`, `retry` purple; `functools` red (Query Difference, below) | `function.decorator`, `attribute` | `@odp.decorator.python`, `@attribute`, `@attribute.builtin` |
| `self`, `cls` | every method | yellow | `variable.special` | `@variable.builtin` |
| Builtin functions | `len`, `isinstance`, `print`, `sorted`, `open` | **Deviation 4**: cyan in Zed, blue in nvim | `function.builtin` | `@odp.function.builtin.python` |
| Type constructors | `range(times)`, `str(path)` | yellow in Zed, blue in nvim (Query Difference, below) | `type.builtin` | `@odp.function.builtin.python` |
| Builtin types in annotations | `int`, `str`, `bool`, `float`, `list[int]`, `int \| None` | yellow | `type.builtin` | Type |
| Classes and exceptions | `Queue`, `Pipeline`, `Path`, `ValueError`, `RuntimeError` | yellow | `type.class` (inherits `type`) | `@type` |
| Constants | `MAX_RETRIES`, `DEFAULT_NAME` | orange | `constant` | `@constant` |
| `None` | lines 25, 53, 54, 74 | **Deviation 5**: purple in Zed, orange in nvim | `constant.builtin` | `@constant.builtin.python` |
| `True`, `False`, numbers | `True`, `False`, `3`, `8`, `2`, `0.5`, `0xFF`, `4` | orange | `boolean`, `number` | Boolean, Number |
| Strings | the docstrings, `"jobs"`, `f"…"`, `r"C:\raw\path"`, `b"bytes"` | green | `string` | `@string` |
| Escapes | `\n`, `\t` in `"idle\n"`, `"busy\t"` | cyan | `string.escape` | `@string.escape` |
| f-string braces | `{times}`, `{item!r}`, `{label}{n:>4}` | **Deviation 9**: fg in Zed, purple in nvim | `punctuation.special` | `@odp.punctuation.special.python` |
| Splat operators | `*args`, `**kwargs`, `*self.items` | **Deviation 8**: cyan in Zed, fg in nvim | `operator` | `@odp.operator.splat.python` |
| Brackets | `(` `)` `[` `]` `{` `}` | **Deviation 1**: purple in Zed, orange in nvim | `punctuation.bracket` | `@odp.punctuation.bracket.python` |
| Variables, parameters, attributes | `item`, `last`, `q`, `fn`, `.items`, `.limit`, `os.environ` | red | `variable`, `variable.parameter`, `property` | `@variable`, `@variable.parameter`, `@variable.member` |
| Operators | `=`, `==`, `>=`, `>`, `->`, `/`, `*` | cyan | `operator` | `@operator` |
| Delimiters | `.`, `,`, `:` | fg | `punctuation.delimiter` | Delimiter |
| Comments | `# a trailing comment` | comment | `comment` | Comment |

Deviations: 1, 4, 5, 8, 9.

Query Differences in this sample:

- **Decorator names** `dataclass`, `retry`, and the `functools` in `@functools.wraps`: blue in Zed, where the whole decorator is `function.decorator`; in nvim the `@` is blue (Upstream's `@odp.decorator.python`), the name purple (the global `@attribute`), `functools` red. `property`, `classmethod` and `wraps` are blue in both. Zed sends only the three builtin decorators to `attribute`, which is why `attribute` is blue (its entry in `scripts/mapping.lua`).
- **Type constructors** `range(times)`, `str(path)`: yellow in Zed, which names them `type.builtin` in call position, blue in nvim (`@odp.function.builtin.python`). The same tokens would be cyan under Deviation 4 if Zed named them `function.builtin`.

- **Keyword-argument names** `name=`, `times=`, `sep=`, `file=`, `encoding=`, `default_factory=`: blue in Zed (`function.kwargs`, which inherits `function`), red in nvim (`@variable.parameter`). Closable by giving `function.kwargs` its own Syntax Key, red; a follow-up decision.
- **Imported names** `functools`, `os`, `dataclasses`, `dataclass`, `field`, `pathlib`: red in Zed (`variable`; `Path` yellow as a class), fg in nvim (Upstream's `@odp.import_module.python`). Zed's query has no capture for import lists.
- **`!r` and `:>4` inside f-strings**: fg in Zed (`embedded`), blue and green in nvim.
- **`list` as a bare argument** (`default_factory=list`): red in Zed, yellow in nvim. Zed names builtin types `type.builtin` only in call and annotation position.
- **The shebang** `#!/usr/bin/env python3`: comment in Zed, purple in nvim (`@keyword.directive`).
- **Dunder names** `__name__`, `__future__`, and the `_` wildcard in `case _:`: red, fg and fg in Zed; orange, blue and purple in nvim.

---

## Terraform: `samples/sample.tf`

Spec story 10. Zed needs the Terraform extension (installed).

| Token class | In the sample | Expected | Zed Syntax Key | nvim group |
| --- | --- | --- | --- | --- |
| Top-level block types | `terraform`, `provider`, `variable`, `locals`, `data`, `resource`, `module`, `output` | purple | `keyword` | `@keyword` |
| Nested block types | `required_providers`, `validation`, `filter`, `root_block_device`, `lifecycle`, `dynamic`, `content` | yellow | `type` | `@type` |
| Attributes | `required_version`, `region`, `type`, `default`, `condition`, `ami`, `count`, `tags` | red | `variable` | `@variable.member` |
| Strings | `">= 1.6"`, `"hashicorp/aws"`, `"${var.region}-queue"`, the heredoc body | green | `string` | `@string` |
| Escapes | `\t`, `\n` in `"ready\tfor ${var.region}\n"` | green, as string text: neither Zed's nor nvim-treesitter's HCL query has an escape capture | `string` | `@string` |
| Interpolation markers | `${` and `}` in `"${var.region}-queue"` and the heredoc | fg | `punctuation.special` | `@punctuation.special` |
| Heredoc markers | `<<-EOT`, `EOT` | fg | `punctuation.delimiter` | `@punctuation.delimiter` |
| Functions | `map`, `cidrsubnet`, `merge`, `format`, `toset` | blue | `function` | `@function` |
| Type keywords | `string`, `number`, `map`, `bool`, `list` | yellow | `type` | `@type.builtin` |
| Numbers, booleans, `null` | `3`, `0`, `10`, `8`, `1`, `80`, `443`, `20`, `true`, `false`, `null` | orange | `number`, `boolean`, `constant` | Number, Boolean, `@constant` |
| Expression keywords | `for`, `in`, `if` in `[for p in … : p if p != 8080]` | purple | `keyword` | `@keyword.repeat`, `@keyword.conditional` |
| Operators | `==`, `>`, `<=`, `&&`, `!=` | cyan | `operator` | `@operator` |
| `?`, `:`, `=`, `=>` | the conditionals and every assignment | fg | `punctuation.special`, `punctuation` | `@punctuation.special`, `@none` |
| Brackets | `{` `}` `[` `]` `(` `)` | purple | `punctuation.bracket` | `@punctuation.bracket` |
| Comments | `#`, `//` and `/* */` | comment | `comment` | Comment |

Deviations: none apply to Terraform.

Query Differences in this sample:

- **Reference roots** `var`, `local`, `data`, `module`, and the first element of any dotted reference (`aws_instance` in `aws_instance.queue[*].id`, `ingress` in `ingress.value`), plus `.module` after `path` and `.workspace` after `terraform`: red in Zed (`variable`), yellow in nvim (`@variable.builtin`). The Zed extension copied nvim-treesitter's query and renamed `@variable.builtin` to `@variable`. `path` and `terraform` themselves are yellow in both; the attribute after the dot (`.region`, `.name`, `.id`) is red in both.

---

## YAML: `samples/sample.yml`

Spec story 11. Compare as plain YAML in both editors (see Setup).

| Token class | In the sample | Expected | Zed Syntax Key | nvim group |
| --- | --- | --- | --- | --- |
| Keys | `name`, `hosts`, `become`, `vars`, `ansible.builtin.apt`, `<<`, `soft` | red | `property` | `@property` |
| String values | `jobs`, `queue`, `redis-server`, `"python3-redis"`, `'single quotes …'`, `yes`, `present`, `"0644"`, `"{{ item }}"` | green | `string` | `@string` |
| Block scalars | the `\|` and `>` bodies, the vault body | green | `string` | `@string` |
| Escapes | `\n` in `"Welcome to {{ inventory_hostname }}\n"` | cyan | `string.escape` | `@string.escape` |
| Numbers | `8`, `0.5`, `3`, `1024`, `2048`, `3600` | orange | `number` | Number |
| Booleans | `true`, `false` | orange | `boolean` | Boolean |
| Null | `~`, `null` | purple | `constant.builtin` | `@constant.builtin` |
| Tags | `!vault` | yellow | `type` | `@type` |
| Anchor and alias markers | `&`, `*` in `&defaults`, `*defaults` | fg | `punctuation.special` | `@punctuation.special` |
| Document markers | `---`, `...` | fg | `punctuation.special` | `@punctuation.special` |
| Indicators | `-`, `:`, `\|`, `>` | fg | `punctuation.delimiter` | `@punctuation.delimiter` |
| Flow brackets | `[redis-server, "python3-redis"]`, `{ soft: 1024, hard: 2048 }`, `[config, queue]` | **Deviation 1**: purple in Zed, orange in nvim | `punctuation.bracket` | `@punctuation.bracket.yaml` |
| Comments | the `#` lines | comment | `comment` | Comment |

Deviations: 1.

Query Differences in this sample:

- **Anchor and alias names** `defaults` in `&defaults` and `*defaults`: yellow in Zed (`type`), purple in nvim (`@label`).

`{{ item }}` and the other Jinja inside strings are plain string text, green, in both editors when the file is opened as YAML. Under Zed's Ansible language or nvim's `yaml.ansible` filetype they are injected and recoloured by those grammars, which this theme does not control.

---

## Markdown: `samples/sample.md`

Spec story 12. In nvim, set `conceallevel=0` and disable render-markdown first (see Setup).

| Token class | In the sample | Expected | Zed Syntax Key | nvim group |
| --- | --- | --- | --- | --- |
| Heading 1 | `# OneDarkPro sample` | red, bold | `title` | `@markup.heading.1.markdown` |
| Headings 2 to 6 | `## Emphasis and code`, `### Links`, the setext heading | red, bold in Zed. nvim: orange bold for level 2, yellow bold for level 3, then green, blue, cyan, purple (Query Difference, below) | `title` | `@markup.heading.N.markdown` |
| Emphasis | `*emphasis*`, `*em*` | purple, italic | `emphasis` | `@markup.italic.markdown_inline` |
| Strong emphasis | `**strong emphasis**`, `**strong**` | orange, bold | `emphasis.strong` | `@markup.strong.markdown_inline` |
| Inline code | `` `inline code` ``, `` `code` `` | green, backticks included | `text.literal` | `@markup.raw.markdown_inline` |
| Link text | `inline link`, `reference link`, `palette` | blue | `link_text` | `@markup.link.label` |
| Link URLs | the two GitHub URLs, `palette.png`, `<https://zed.dev>` | purple | `link_uri` | `@markup.link.url` |
| Reference definition | `[upstream]: https://… "Upstream"` | label and title blue, URL purple | `link_text`, `link_uri` | `@markup.link.label`, `@markup.link.url` |
| List markers | `-`, `*`, `+`, `1.`, `2.` | yellow | `punctuation.list_marker` | `@markup.list.markdown` |
| Block quote marker | the two `>` | comment | `punctuation.markup` | `@punctuation.special.markdown` |
| Table pipes and delimiter row | `\|`, `------` | comment | `punctuation.markup` | `@punctuation.special.markdown` |
| Fenced code | the Go inside the fence | highlighted as Go in both | (Go grammar) | (go parser) |
| Plain text | paragraphs | fg | `text` (no Syntax Key; editor foreground) | fg |

Deviations: none apply to Markdown.

Query Differences in this sample:

- **Heading levels.** Zed's Markdown grammar emits one `title` capture for every heading, so all levels are red bold. nvim shows levels in Upstream's rainbow order (red, orange, yellow, green, blue, cyan, purple) through Upstream's render-markdown groups `@markup.heading.N.markdown`, which are defined whether or not render-markdown is running. Level 1 matches.
- **Link brackets and parentheses** `[` `]` `(` `)`: blue and purple in Zed, fg in nvim (and concealed there by default).
- **Block quote text**: fg in Zed (no capture beyond `text`), comment in nvim (`@markup.quote.markdown`).
- **Indented code block**: fg in Zed (`text`), green in nvim (`@markup.raw.block`).
- **Fences and info string** `` ```go ``, `` ``` ``: fg in Zed (`punctuation.embedded`); nvim conceals them and shows green when `conceallevel=0`.
- **Table header cells** `Column`, `Value`: fg in Zed, red bold in nvim (`@markup.heading`).
- **Horizontal rule** `---`: red bold in Zed (its grammar names it `title`), comment in nvim.
- **Checked task box** `[x]`: fg in Zed, purple in nvim.

---

## Shell: `samples/sample.sh`

Spec story 13.

| Token class | In the sample | Expected | Zed Syntax Key | nvim group |
| --- | --- | --- | --- | --- |
| Command substitution and expansions | `$(` `)`, `$` in `$1`, `${` `}`, `$((` `))` | fg | `punctuation.special` | `@punctuation.special` |
| Keywords | `if`, `then`, `elif`, `fi`, `for`, `in`, `do`, `done`, `while`, `until`, `case`, `esac`, `function`, `local`, `declare`, `export` | purple | `keyword`, `keyword.control` | `@keyword.*` |
| Shebang | `#!/usr/bin/env bash` | purple | `keyword.directive` (inherits `keyword`) | `@keyword.directive` |
| Function names and commands | `usage`, `log`, `cat`, `mkdir`, `ping`, `sleep`, `dpkg`, `apt-get`, `find`, `wc`, `date` | blue | `function` | `@function`, `@function.call` |
| Variables | `attempt`, `count`, `pkg`, `level`, `opt`, `packages` | red | `variable` | `@variable` |
| Strings | `"…"`, `'…'`, `$'ANSI-C string with a tab\there'`, the heredoc body | green | `string` | `@string` |
| Numbers | `3`, `0`, `1`, `64`, `100` | orange | `number` | Number |
| Operators | `\|\|`, `&&`, `\|`, `>`, `>&2`, `=~`, `+`, `-`, `*`, `/`, `=` | cyan | `operator` | `@operator` |
| Brackets | `[[ ]]`, `(( ))`, `{ }`, `( )` | purple | `punctuation.bracket` | `@punctuation.bracket` |
| Delimiters | `;`, `;;` | fg | `punctuation.delimiter` | `@punctuation.delimiter` |
| Comments | the `#` lines | comment | `comment` | Comment |

Deviations: none apply to shell.

Query Differences in this sample. Zed's bash query is the furthest from nvim-treesitter's of the six, so expect these:

- **Builtin commands** `set`, `shift`, `printf`, `echo`, `exit`, `getopts`, `break`: blue in Zed (`function`), yellow in nvim (`@function.builtin`).
- **Uppercase variable names** `MAX_RETRIES`, `QUEUE_NAME`, `QUEUE_DIR`, `DRY_RUN`, `VERBOSE`: red in Zed, orange in nvim (`@constant` by case). Bash's own `OPTARG`, `OPTIND`: red in Zed, yellow in nvim.
- **Bare-word arguments** `pipefail`, `warn`, `info`, `error`, `install`, `queue.internal`, `+%T`, `f`: green in Zed (`string`), red in nvim (`@variable.parameter`).
- **Flags** `-euo`, `-p`, `-c`, `-W`, `-s`, `-y`, `-type`, `-name`, `-l`, `-e`: orange in Zed (`constant`), red in nvim.
- **Test operators** `-d`, `-z`, `-ge`, `-gt`: purple in Zed (`keyword.operator`), cyan in nvim.
- **Special variables** `$*`, `$#`, `$?`: the character after `$` yellow in Zed (`variable.special`), orange in nvim.
- **`case` patterns** `n)`, `v)`, `\?)`: green in Zed (`string.regex`), red in nvim.
- **Heredoc delimiter** `EOF`: green in Zed (`string`), purple in nvim (`@label`).
- **Regex** `^python3-`: green in Zed (`string.regex`), blue in nvim. Upstream's `@string.regex` is the pre-0.10 capture name; nvim-treesitter now emits `@string.regexp`, which nvim links to `@string.special`, Special, blue. A follow-up could move `string.regex` to blue to match what nvim shows.
- **Redirect targets** `/dev/null`: green in Zed, blue in nvim (`@string.special.path`). **File descriptors** `2` in `2>&1`: orange in Zed, cyan in nvim. **`&>`**: fg in Zed, cyan in nvim.
- **`readonly`**: fg in Zed (no capture), purple in nvim. **`@` in `"${packages[@]}"`**: green in Zed, purple in nvim.

---

## Chrome (Zed only)

Spec stories 14 to 41. Style Keys are in `scripts/mapping.lua` under the Chrome Rule named; the expected value is the Palette colour, composited over its surface where alpha applies. Check both Variants.

| # | Check | How to see it | Expected |
| --- | --- | --- | --- |
| 14 | No italics or bold outside Markdown | any code sample | plain weight everywhere; only Markdown headings, `**strong**` and `*emphasis*` carry a style |
| 15 | Brackets | any code sample | purple |
| 16 | Inlay hints | `inlay_hints.enabled`, open `sample.go` with gopls | `inlay_hint` |
| 17 | Comments | any sample | `comment`, not Zed One Dark's darker grey |
| 18 | Active line | click a line | `editor.active_line.background` = `cursorline` |
| 19 | Line numbers | gutter | active line number purple; others `line_number` |
| 20 | Selection | select text | `selection` (player one) |
| 21 | Cursor | | purple |
| 22 | Search | `cmd-f` for `queue` | matches `highlight` at 30%, active match at 55% (composites below) |
| 23 | Indent guides | any indented sample | `indentline`; the guide of the indent level the cursor is in, blue |
| 24 | Invisibles and placeholders | `show_whitespaces: all`; an empty search box | gray |
| 25 | Editor, project panel, panels, active tab | | `bg` |
| 26 | Status bar, title bar, tab bar, inactive tabs | | `bg_statusline` |
| 27 | Popups, menus, pickers | command palette, file finder, completions | `float_bg` |
| 28 | Menu rows | hover and arrow through the command palette | hovered row `cursorline`, selected row `selection` |
| 29 | Pane splits | `pane: split right` | `gray` |
| 30 | Other borders | panel edges, popup borders | `fg_gutter` |
| 31 | Focus and links | focused pane border; a link in a hover popup | purple; blue |
| 32 | Terminal ANSI colours | the colour test below, in Zed's terminal and in ghostty | identical slot for slot |
| 33 | Faint terminal text | the last line of the colour test | the normal colour at 70% alpha (Zed renders SGR 2 itself; the Theme's 60% `dim_*` keys are not reachable from escape sequences) |
| 34 | Terminal surface | | background `bg`, foreground `fg` |
| 35 | Diagnostics | delete a `)` in `sample.go` with gopls running | error red, warning yellow, info blue, hint cyan; popup tint at 15%, border at 50% |
| 36 | Project panel git status | edit a sample; add a new file; a `.gitignore`d file | modified yellow, created green, deleted red, renamed and conflict blue, ignored gray |
| 37 | Diff hunks | the gutter after an edit; `git: diff` | added `diff_add`, deleted `diff_delete`; hollow borders green and red |
| 38 | Word-level diff | the project diff | `diff_text` added, `diff_text_delete` deleted |
| 39 | Vim mode indicator | status bar in each mode | normal green, insert blue, visual yellow, replace red; text `bg` |
| 40 | Accents | `indent_guides.coloring: indent_aware` | guides cycle red, yellow, blue, orange, green, purple, cyan |
| 41 | Collaborator cursors | a collab session, or `themes/onedarkpro.json` `players` | player one purple; then blue, green, yellow, red, cyan, orange, gray |

Alpha composites over `bg` for an eyedropper:

| Tint | Onedark | Onelight |
| --- | --- | --- |
| Search match, `highlight` at 30% | #60584a | #f3e8d4 |
| Search active match, `highlight` at 55% | #8e7c5c | #edd9b5 |
| Scrollbar and minimap thumb, `gray` at 40% | #3d424c | #e2e2e2 |

## Terminal colour test

Run in Zed's terminal and in ghostty, with the same Variant in both:

```sh
for i in 0 1 2 3 4 5 6 7; do printf '\033[3%dm %d:text \033[0m' "$i" "$i"; done; printf '\n'
for i in 0 1 2 3 4 5 6 7; do printf '\033[9%dm %d:bright \033[0m' "$i" "$i"; done; printf '\n'
for i in 0 1 2 3 4 5 6 7; do printf '\033[4%dm  %d  \033[0m' "$i" "$i"; done; printf '\n'
for i in 0 1 2 3 4 5 6 7; do printf '\033[10%dm  %d  \033[0m' "$i" "$i"; done; printf '\n'
printf 'normal   \033[2mfaint (SGR 2)\033[0m   \033[2;31mfaint red\033[0m   \033[31mred\033[0m\n'
```

Expected: slots 0 to 7 are `black`, `red`, `green`, `yellow`, `blue`, `purple`, `cyan`, `white`; slots 8 to 15 are `gray` then the Bright Colours. In Onelight slot 0 is the dark grey (#6a6a6a) and slot 7 the near-white (#fafafa), as in ghostty. Faint text is the normal colour at 70% in Zed.

## Palette reference

Copied from `palettes/onedark.json` and `palettes/onelight.json` at Upstream 24c806c. The Palette files are the record; after a re-sync, read the values there.

Base colours:

| Colour | Onedark | Onelight |
| --- | --- | --- |
| bg | #282c34 | #fafafa |
| fg | #abb2bf | #6a6a6a |
| red | #e06c75 | #e05661 |
| orange | #d19a66 | #ee9025 |
| yellow | #e5c07b | #eea825 |
| green | #98c379 | #1da912 |
| cyan | #56b6c2 | #56b6c2 |
| blue | #61afef | #118dc3 |
| purple | #c678dd | #9a77cf |
| white | #abb2bf | #fafafa |
| black | #282c34 | #6a6a6a |
| gray | #5c6370 | #bebebe |
| highlight | #e2be7d | #e2be7d |
| comment | #7f848e | #9b9fa6 |

Derived Colours the Chrome uses:

| Colour | Onedark | Onelight |
| --- | --- | --- |
| bg_statusline | #22262d | #f3f3f3 |
| cursorline | #2d313b | #f4f4f4 |
| float_bg | #21252b | #efefef |
| selection | #414858 | #e9e9e9 |
| fg_gutter | #3d4350 | #e1e1e1 |
| line_number | #495162 | #cccccc |
| indentline | #3b4048 | #e7e7e7 |
| fold | #30333d | #f2f2f2 |
| inlay_hint | #4c525c | #d8d8d8 |
| diff_add | #353e3c | #dff0de |
| diff_change | #3b3b3b | #f9f2e5 |
| diff_delete | #3e343c | #f7e6e8 |
| diff_text | #344f58 | #d1e9ec |
| diff_text_delete | #563c44 | #f3d1d4 |
| git_add | #405f2b | #85f17c |
| git_change | #a67821 | #f9e1b3 |
| git_delete | #7f1b22 | #fcedee |
| bright_fg | #c8cdd5 | #848484 |

The full Palette of each Variant, Bright Colours included, is in `palettes/onedark.json` and `palettes/onelight.json`.

## Signing off

- [ ] Six samples compared in Onedark, nvim beside Zed; differences limited to the Deviations and Query Differences above
- [ ] The same six in Onelight
- [ ] Chrome checks 14 to 41 in both Variants
- [ ] Terminal colour test matches ghostty in both Variants

All ticked: close spec #1. Otherwise file one issue per finding, naming the sample and line (or the Chrome check number), the Syntax Key or Style Key, and the colour seen in each editor.
