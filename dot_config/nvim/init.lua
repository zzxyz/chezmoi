-- ============================================================================
-- NEOVIM CONFIGURATION
-- ============================================================================
-- Modern Neovim setup with lazy.nvim, Treesitter, and LSP
-- Companion to ~/.vimrc (which remains available via 'vim' command)

-- ============================================================================
-- BASIC SETTINGS (matching .vimrc behavior)
-- ============================================================================
vim.opt.syntax = 'on'
vim.opt.number = true              -- Show line numbers
vim.opt.relativenumber = false     -- Absolute line numbers

-- Search settings
vim.opt.incsearch = true           -- Incremental search
vim.opt.hlsearch = true            -- Highlight search results
vim.opt.ignorecase = true          -- Case insensitive search
vim.opt.smartcase = true           -- Case sensitive if uppercase present

-- Tab settings
vim.opt.tabstop = 4
vim.opt.softtabstop = 0
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.smarttab = true
vim.opt.smartindent = true

-- Undo settings
vim.opt.undofile = true
vim.opt.undodir = vim.fn.expand('~/.config/nvim/undo')
vim.fn.system('mkdir -p ' .. vim.fn.expand('~/.config/nvim/undo'))

-- Other settings
vim.opt.hidden = true              -- Allow hidden buffers
vim.opt.formatoptions:remove('cro') -- Disable auto-commenting
vim.opt.termguicolors = true       -- 24-bit color support
vim.opt.background = 'dark'
-- Clipboard configuration: Explicitly configure to avoid slow auto-detection (739ms!)
-- Priority: win32yank (WSL) > wl-clipboard (Wayland) > xclip (X11)
if vim.fn.executable('win32yank.exe') == 1 then
  vim.g.clipboard = {
    name = 'win32yank',
    copy = {
      ['+'] = 'win32yank.exe -i --crlf',
      ['*'] = 'win32yank.exe -i --crlf',
    },
    paste = {
      ['+'] = 'win32yank.exe -o --lf',
      ['*'] = 'win32yank.exe -o --lf',
    },
    cache_enabled = 0,
  }
elseif vim.fn.executable('wl-copy') == 1 and vim.fn.executable('wl-paste') == 1 then
  vim.g.clipboard = {
    name = 'wl-clipboard',
    copy = {
      ['+'] = 'wl-copy',
      ['*'] = 'wl-copy --primary',
    },
    paste = {
      ['+'] = 'wl-paste --no-newline',
      ['*'] = 'wl-paste --no-newline --primary',
    },
    cache_enabled = 1,
  }
elseif vim.fn.executable('xclip') == 1 then
  vim.g.clipboard = {
    name = 'xclip',
    copy = {
      ['+'] = 'xclip -selection clipboard',
      ['*'] = 'xclip -selection primary',
    },
    paste = {
      ['+'] = 'xclip -selection clipboard -o',
      ['*'] = 'xclip -selection primary -o',
    },
    cache_enabled = 1,
  }
end
vim.opt.clipboard = 'unnamedplus'  -- Use system clipboard
vim.opt.mouse = 'a'                -- Enable mouse support

-- ============================================================================
-- KEY MAPPINGS (matching .vimrc)
-- ============================================================================
-- Set leader key (useful for plugin mappings)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Buffer navigation (F1/F3 like in .vimrc)
vim.keymap.set('n', '<F1>', ':bprev<CR>', { silent = true })
vim.keymap.set('n', '<F3>', ':bnext<CR>', { silent = true })

-- Tag navigation (F4/F5)
vim.keymap.set('n', '<F4>', ':tprev<CR>', { silent = true })
vim.keymap.set('n', '<F5>', ':tnext<CR>', { silent = true })

-- Quickfix navigation (F6/F7)
vim.keymap.set('n', '<F6>', ':cprevious<CR>', { silent = true })
vim.keymap.set('n', '<F7>', ':cnext<CR>', { silent = true })

-- Use semicolon as colon (faster command entry)
vim.keymap.set('n', ';', ':', { noremap = true })
vim.keymap.set('v', ';', ':', { noremap = true })

-- ============================================================================
-- LAZY.NVIM PLUGIN MANAGER BOOTSTRAP
-- ============================================================================
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ============================================================================
-- PLUGIN SPECIFICATIONS
-- ============================================================================
require('lazy').setup({
  -- Color scheme (Gruvbox)
  {
    'morhetz/gruvbox',
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd('colorscheme gruvbox')
    end,
  },

  -- Git integration (vim-fugitive)
  {
    'tpope/vim-fugitive',
  },

  -- Note: Commenting with gcc is built into nvim 0.10+, no plugin needed!

  -- Fuzzy finder (Telescope - replacement for ctrlp)
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('telescope').setup({
        defaults = {
          mappings = {
            i = {
              ['<C-j>'] = 'move_selection_next',
              ['<C-k>'] = 'move_selection_previous',
            },
          },
        },
      })

      -- Key mappings for Telescope
      vim.keymap.set('n', '<C-p>', '<cmd>Telescope find_files<cr>', { desc = 'Find files' })
      vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', { desc = 'Live grep' })
      vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<cr>', { desc = 'Find buffers' })
      vim.keymap.set('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', { desc = 'Help tags' })
    end,
  },

  -- Treesitter for better syntax highlighting
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      -- Modern nvim-treesitter setup (post-rewrite API)
      -- The old require('nvim-treesitter.configs') API NO LONGER EXISTS

      -- Arch Linux NOTE: Use system-provided parsers via pacman!
      -- Install with: sudo pacman -S tree-sitter-{lua,python,bash,etc}
      -- System parsers are in /usr/lib/tree_sitter/ (automatically detected by nvim)
      -- DO NOT use :TSInstall - it will conflict with system packages!

      -- Basic setup (optional, uses defaults if omitted)
      require('nvim-treesitter').setup({
        -- Don't auto-install parsers - we use system packages on Arch
        -- (Other distros may need manual installation)
      })

      -- Enable treesitter highlighting automatically for all filetypes
      vim.api.nvim_create_autocmd('FileType', {
        callback = function()
          -- pcall in case parser not installed for this filetype
          pcall(vim.treesitter.start)
        end,
      })
    end,
  },

  -- LSP Configuration (commented out for now - bashls install failed, API deprecated in nvim 0.11)
  -- Uncomment and update if you want LSP support later
  -- {
  --   'neovim/nvim-lspconfig',
  --   dependencies = {
  --     'williamboman/mason.nvim',
  --     'williamboman/mason-lspconfig.nvim',
  --   },
  --   config = function()
  --     require('mason').setup()
  --     require('mason-lspconfig').setup({
  --       ensure_installed = { 'bashls' },
  --     })
  --     local on_attach = function(client, bufnr)
  --       local opts = { buffer = bufnr, noremap = true, silent = true }
  --       vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  --       vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  --       vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
  --       vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
  --       vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
  --       vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  --     end
  --     require('lspconfig').bashls.setup({ on_attach = on_attach })
  --   end,
  -- },
})

-- ============================================================================
-- ADDITIONAL CONFIGURATION
-- ============================================================================
-- Highlight on yank
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 200 })
  end,
})
