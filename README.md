# QuickClip for Neovim

The goal of QuickClip is to provide a really simple interface that shows you the
last 10 items you have yanked, and lets you quickly pick one by number to paste
back into your buffer.

## Goals

-   Automatically keep a rolling list of the last 10 yanked lines
-   Provide window of the last 10 items where you can press a number and have it
    immediately paste

## Installation

Install using your favorite plugin manager

```text
'bartdorsey/quickclip.nvim'
```

Call the setup function

```lua
require('quickclip').setup()
```

The main command to trigger the window is `QuickClip`

```lua
vim.set.keymap("n", "<leader>p", "<cmd>QuickClip<cr>", { desc = "Open QuickClip" })
```

You can press `q` or `ESC` to close the window, or press the number that appears
to paste that item.
