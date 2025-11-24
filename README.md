# scrollbar.nvim

[![GitHub License](https://img.shields.io/github/license/wsdjeg/scrollbar.nvim)](LICENSE)
[![GitHub Issues or Pull Requests](https://img.shields.io/github/issues/wsdjeg/scrollbar.nvim)](https://github.com/wsdjeg/scrollbar.nvim/issues)
[![GitHub commit activity](https://img.shields.io/github/commit-activity/m/wsdjeg/scrollbar.nvim)](https://github.com/wsdjeg/scrollbar.nvim/commits/master/)
[![GitHub Release](https://img.shields.io/github/v/release/wsdjeg/scrollbar.nvim)](https://github.com/wsdjeg/scrollbar.nvim/releases)
[![luarocks](https://img.shields.io/luarocks/v/wsdjeg/scrollbar.nvim)](https://luarocks.org/modules/wsdjeg/scrollbar.nvim)

![Image](https://github.com/user-attachments/assets/a6fa9d98-fd0c-4a3c-a2c5-512e54a9453a)

scrollbar.nvim is floating scrollbar plugin for neovim.

<!-- vim-markdown-toc GFM -->

- [Installation](#installation)
- [Setup](#setup)
- [Debug](#debug)
- [Self-Promotion](#self-promotion)
- [Credits](#credits)
- [Feedback](#feedback)

<!-- vim-markdown-toc -->

## Installation

Using [nvim-plug](https://github.com/wsdjeg/nvim-plug)

```lua
require('plug').add({
    {
        'wsdjeg/scrollbar.vim',
        config = function()
            require('scrollbar').setup()
        end,
    },
})
```

Using [luarocks](https://luarocks.org/)

```
luarocks install --server=https://luarocks.org/manifests/wsdjeg scrollbar.nvim
```

For vim support, please checkout [v1.0.0](https://github.com/wsdjeg/scrollbar.nvim/releases/tag/v1.0.0):

```
Plug 'wsdjeg/scrollbar.nvim', { 'tag': 'v1.0.0' }
```

## Setup

The default option:

```lua
require('scrollbar').setup({
    max_size = 10,
    min_size = 5,
    width = 1,
    right_offset = 1,
    excluded_filetypes = {
        'startify',
        'git-commit',
        'leaderf',
        'NvimTree',
        'tagbar',
        'defx',
        'neo-tree',
        'qf',
    },
    shape = {
        head = '▲',
        body = '█',
        tail = '▼',
    },
    highlight = {
        head = 'Normal',
        body = 'Normal',
        tail = 'Normal',
    },
})
```

## Debug

Using [logger.nvim](https://github.com/wsdjeg/logger.nvim):

```lua
require('plug').add({
    {
        'wsdjeg/scrollbar.vim',
        config = function()
            require('scrollbar').setup()
        end,
        depends = {
            { 'wsdjeg/logger.nvim' },
        },
    },
})
```

## Self-Promotion

Like this plugin? Star the repository on
GitHub.

Love this plugin? Follow [me](https://wsdjeg.net/) on
[GitHub](https://github.com/wsdjeg) and
[Twitter](http://twitter.com/wsdtty).

## Credits

- [Xuyuanp/scrollbar.nvim](https://github.com/Xuyuanp/scrollbar.nvim)

## Feedback

If you encounter any bugs or have suggestions, please file an issue in the [issue tracker](https://github.com/wsdjeg/scrollbar.vim/issues)
