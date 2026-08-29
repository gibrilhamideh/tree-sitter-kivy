# tree-sitter-kivy

An indentation-aware Tree-sitter grammar for Kivy KV files.

The parser provides an editor-independent concrete syntax tree for KV
structure. The repository also includes queries for Neovim highlighting,
Python expression injection, indentation, folding, and Aerial symbols.

This project is an initial preview. Please report valid KV syntax that produces
an unexpected `ERROR` or `indentation_error` node.

## Features

- KV rules and dynamic classes.
- Root and nested widgets.
- Properties and event handlers.
- Inline and multiline property expressions.
- Parenthesized and backslash continuations.
- `canvas`, `canvas.before`, and `canvas.after` blocks.
- Kivy directives.
- Strings, numbers, operators, comments, and collection literals.
- Explicit `# section:` structural markers.
- Recovery from incomplete syntax while editing.
- `indentation_error` nodes for inconsistent dedents.

## Included queries

| Query | Purpose |
| --- | --- |
| `highlights.scm` | KV syntax highlighting and section highlighting |
| `injections.scm` | Python highlighting inside KV expressions |
| `indents.scm` | Tree-sitter indentation for Neovim |
| `folds.scm` | Widget, rule, expression, and section folding |
| `aerial.scm` | Named symbols for Aerial's Tree-sitter backend |

The parser itself is not specific to Neovim. Editors choose how to compile the
grammar and which query files they support. `aerial.scm` is specifically for
the Neovim Aerial plugin.

## Relationship to kivy-lsp

`tree-sitter-kivy` and `kivy-lsp` solve different parts of KV editing:

| Project | Responsibility |
| --- | --- |
| `tree-sitter-kivy` | Parsing, highlighting, indentation, folding, injections, and structural navigation |
| `kivy-lsp` | Completion, diagnostics, types, navigation, hover, and semantic tokens |

The grammar does not need `kivy-lsp`, and the language server does not require
the Tree-sitter parser. Installing both provides the complete editor
experience.

## Repository layout

```text
tree-sitter-kivy/
├── examples/
├── queries/
│   └── kivy/
├── src/
├── test/
│   └── corpus/
├── grammar.js
├── package.json
└── tree-sitter.json
```

Generated source files such as `src/parser.c`, `src/grammar.json`, and
`src/node-types.json` are committed. Local binaries, `node_modules`, and build
directories are not committed.

## Development requirements

- Node.js and npm.
- Tree-sitter CLI 0.26 or newer.
- A C compiler.

## Build and test

From the repository root:

```bash
npm install
npm run generate
npm test
mkdir -p build
npx tree-sitter build -o build/kivy.so
```

Some npm versions block dependency installation scripts. If the local
Tree-sitter executable is missing after `npm install`, run:

```bash
npm install-scripts approve tree-sitter-cli
npm rebuild tree-sitter-cli
```

Then repeat the generate, test, and build commands.

The generated `src/parser.c` is committed, so editor integrations can compile
the grammar without regenerating it.

## Neovim installation

Neovim needs three things:

1. `.kv` files mapped to the `kivy` filetype.
2. The `kivy` parser registered with `nvim-treesitter`.
3. The queries installed or available on `runtimepath`.

### Install from GitHub

```lua
vim.filetype.add({
  extension = {
    kv = "kivy",
  },
})

vim.api.nvim_create_autocmd("User", {
  pattern = "TSUpdate",

  callback = function()
    require("nvim-treesitter.parsers").kivy = {
      ---@diagnostic disable-next-line: missing-fields
      install_info = {
        url = "https://github.com/"
          .. "gibrilhamideh/tree-sitter-kivy",
        queries = "queries/kivy",
      },

      tier = 3,
    }
  end,
})
```

Add `kivy` to the parser installation list used by your Neovim distribution,
or install it with the command supported by your `nvim-treesitter` version.

For the current `nvim-treesitter` main branch:

```lua
require("nvim-treesitter").install({ "kivy" })
```

For configurations that expose `ensure_installed`:

```lua
opts = function(_, opts)
  opts.ensure_installed = opts.ensure_installed or {}

  if not vim.tbl_contains(opts.ensure_installed, "kivy") then
    table.insert(opts.ensure_installed, "kivy")
  end
end
```

### Use a local checkout

During development, register the separate repository path instead of the old
`kivy-lsp/tree-sitter` directory:

```lua
local kivy_tree_sitter_root = "/path/to/tree-sitter-kivy"

vim.opt.runtimepath:prepend(kivy_tree_sitter_root)

vim.api.nvim_create_autocmd("User", {
  pattern = "TSUpdate",

  callback = function()
    require("nvim-treesitter.parsers").kivy = {
      ---@diagnostic disable-next-line: missing-fields
      install_info = {
        path = kivy_tree_sitter_root,
        queries = "queries/kivy",
      },

      tier = 3,
    }
  end,
})
```

Set `kivy_tree_sitter_root` to the absolute path of the separate
`tree-sitter-kivy` checkout. It must not be derived from `kivy_lsp_root`.

### Enable highlighting, folding, and indentation

Current Neovim and `nvim-treesitter` versions can enable these features with a
filetype autocommand:

```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = "kivy",

  callback = function()
    vim.treesitter.start()
    vim.wo.foldmethod = "expr"
    vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.bo.indentexpr =
      "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})
```

Some Neovim distributions configure these features automatically.

### Verify the installation

Open a `.kv` file and run:

```vim
:set filetype?
:InspectTree
:checkhealth vim.treesitter
```

The filetype should be `kivy`, and `:InspectTree` should show a structured KV
tree without query errors.

## Aerial

The included `queries/kivy/aerial.scm` file exposes KV rules, widgets,
properties, and named sections to Aerial.

After installing the parser and queries, run:

```vim
:AerialInfo
```

The `treesitter` backend should report `supported`. No document-symbol support
from `kivy-lsp` is required.

## Named sections

Use an explicit section marker to create a named Aerial entry and foldable
structural region:

```kv
# ========================================= #
# section: Stage Navigator
# ========================================= #
FnBoxLayout:
    orientation: "horizontal"
```

Directly adjacent comment lines belong to the section header and receive the
same special highlight. A blank line ends the attached comment group:

```kv
# section: Stage Navigator

# This is an ordinary comment.
```

Ordinary code following the section is never colored as a comment.

The section body continues until the next section at the same indentation or
until the enclosing block ends. Folding a section hides the body while keeping
the section marker and its attached decorative comments visible.

Nested sections belong to their enclosing section. Folding a parent section
therefore hides nested sections; after expanding the parent, each nested
section can be folded independently.

## Manual parser installation

If an editor integration cannot build the parser automatically:

```bash
mkdir -p build
npx tree-sitter build -o build/kivy.so
install -Dm755 \
  build/kivy.so \
  ~/.local/share/nvim/site/parser/kivy.so
```

The query directory must still be on Neovim's `runtimepath`.

## Contributing

Grammar changes should include a corpus test in `test/corpus`. Run:

```bash
npm run generate
npm test
```

Commit regenerated parser sources whenever `grammar.js` or `src/scanner.c`
changes. Do not commit `node_modules`, `parser.so`, or the `build` directory.

## License

MIT
