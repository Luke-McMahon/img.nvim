# img.nvim

Open images from Neovim in your default system viewer.

## Requirements

- Neovim 0.10+
- [oil.nvim](https://github.com/stevearc/oil.nvim)

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  'luke-mcmahon/img.nvim',
  dependencies = { 'stevearc/oil.nvim' },
  config = function()
    require('img').setup()
  end,
}
```

## Usage

1. Open oil.nvim (`:Oil` or however you have it mapped)
2. Navigate to an image file
3. Press `<CR>` - the image opens in your default viewer

Non-image files work normally (passed through to oil).

## Configuration

```lua
require('img').setup({
  -- File extensions treated as images
  extensions = { 'png', 'jpg', 'jpeg', 'gif', 'webp', 'bmp', 'svg', 'ico', 'tiff', 'tif' },
})
```

## Commands

| Command | Description |
|---------|-------------|
| `:ImgOpen` | Open image under cursor (when in oil buffer) |

## How it works

- Hooks into oil.nvim via FileType autocmd
- Overrides `<CR>` in oil buffers
- Detects image files by extension
- Opens images via `vim.ui.open()` (cross-platform)
- Falls back to opening containing directory on failure
