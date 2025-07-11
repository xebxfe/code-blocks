# code-blocks

A plugin that enables mark-down style code blocks in any file.

## Features
- Uses treesitter for syntax highlighting
- Pre-defined color themes for easy styling
- Toggle code block markers
- Automatic highlighting

## Screenshot
<img width="1626" height="668" alt="image" src="https://github.com/user-attachments/assets/a1f551c8-4a36-4107-a8f8-d4a1f3d8148b" />


## Installation

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'xebxfe/code-blocks',
  config = function()
    require('code-blocks').setup()
  end
}
```

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'xebxfe/code-blocks',
  config = function()
    require('code-blocks').setup()
  end
}
```

## Configuration

```lua
require('code-blocks').setup({
  theme = nil,           -- use a theme for code blocks
  language_color = nil,  -- override the theme for color of language text
  use_treesitter = true, -- enable treesitter for syntax highlighting
  hide_markers = false,  -- don't show the code block markers
})
```

## Available themes

- `catppuccin_mocha` / `catppuccin_latte`
- `dracula`
- `github_dark` / `github_light`
- `gruvbox_dark` / `gruvbox_light`
- `kanagawa`
- `nord`
- `onedark`
- `rose_pine` / `rose_pine_dawn`
- `solarized_dark` / `solarized_light`
- `tokyonight_night` / `tokyonight_day`

## Usage

### Commands

- `:CodeBlockCreate [language]` Create a new code block with optional language tag
- `:CodeBlockToggle` Toggle the code block at the cursor position
- `:CodeBlockTheme [theme]` List available themes, or set optional theme for the current session
- `:CodeBlockHideMarkers` Toggle the code block markers

## Requirements
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) If you want syntax highlighting
- Treesitter language parsers installed for the languages you choose: `TSInstall <language>`



