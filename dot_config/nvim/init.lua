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
      -- Detect if we're on Windows (UCRT64 has system parsers)
      local is_windows = vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1

      require('nvim-treesitter.configs').setup({
        -- Windows: Use system-provided parsers from UCRT64 to avoid conflicts
        -- Linux: Auto-install parsers (requires gcc)
        auto_install = not is_windows,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true,
        },
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
