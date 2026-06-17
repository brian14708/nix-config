vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

vim.loader.enable()

vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.showmode = false
vim.opt.confirm = true
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 200
vim.opt.timeoutlen = 400
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.splitkeep = "screen"
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣", extends = "›", precedes = "‹" }
vim.opt.inccommand = "split"
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.completeopt = { "menuone", "noselect" }
vim.opt.pumheight = 10
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.shm:append("I")

vim.keymap.set("", "<leader>y", '"+y', { noremap = true, desc = "Yank to clipboard" })
vim.keymap.set("", "<leader>p", '"+p', { noremap = true, desc = "Paste from clipboard" })
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
  callback = function()
    (vim.hl or vim.highlight).on_yank()
  end,
})

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    error("Error cloning lazy.nvim:\n" .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { "tpope/vim-sleuth", event = { "BufReadPost", "BufNewFile" } },

  {
    "lewis6991/gitsigns.nvim",
    event = "VeryLazy",
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
      on_attach = function(bufnr)
        local gitsigns = require("gitsigns")

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        map("n", "]c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gitsigns.nav_hunk("next")
          end
        end, { desc = "Jump to next git [c]hange" })

        map("n", "[c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gitsigns.nav_hunk("prev")
          end
        end, { desc = "Jump to previous git [c]hange" })

        map("v", "<leader>hs", function()
          gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "stage git hunk" })
        map("v", "<leader>hr", function()
          gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { desc = "reset git hunk" })
        map("n", "<leader>hs", gitsigns.stage_hunk, { desc = "git [s]tage hunk" })
        map("n", "<leader>hr", gitsigns.reset_hunk, { desc = "git [r]eset hunk" })
        map("n", "<leader>hS", gitsigns.stage_buffer, { desc = "git [S]tage buffer" })
        map("n", "<leader>hu", gitsigns.undo_stage_hunk, { desc = "git [u]ndo stage hunk" })
        map("n", "<leader>hR", gitsigns.reset_buffer, { desc = "git [R]eset buffer" })
        map("n", "<leader>hp", gitsigns.preview_hunk, { desc = "git [p]review hunk" })
        map("n", "<leader>hb", gitsigns.blame_line, { desc = "git [b]lame line" })
        map("n", "<leader>hd", gitsigns.diffthis, { desc = "git [d]iff against index" })
        map("n", "<leader>hD", function()
          gitsigns.diffthis("@")
        end, { desc = "git [D]iff against last commit" })
        map("n", "<leader>tb", gitsigns.toggle_current_line_blame, { desc = "[T]oggle git show [b]lame line" })
        map("n", "<leader>tD", gitsigns.toggle_deleted, { desc = "[T]oggle git show [D]eleted" })
      end,
    },
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      icons = { mappings = vim.g.have_nerd_font, keys = {} },
      spec = {
        { "<leader>c", group = "[C]ode", mode = { "n", "x" } },
        { "<leader>d", group = "[D]ocument" },
        { "<leader>r", group = "[R]ename" },
        { "<leader>s", group = "[S]earch" },
        { "<leader>w", group = "[W]orkspace" },
        { "<leader>t", group = "[T]oggle" },
        { "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
      },
    },
  },

  {
    "ibhagwan/fzf-lua",
    cmd = { "FzfLua" },
    -- stylua: ignore
    keys = {
      { "<leader>sh", desc = "[S]earch [H]elp" },
      { "<leader>sk", desc = "[S]earch [K]eymaps" },
      { "<leader>sf", desc = "[S]earch [F]iles" },
      { "<leader>ss", desc = "[S]earch [S]elect" },
      { "<leader>sw", desc = "[S]earch current [W]ord" },
      { "<leader>sg", desc = "[S]earch by [G]rep" },
      { "<leader>sd", desc = "[S]earch [D]iagnostics" },
      { "<leader>sr", desc = "[S]earch [R]esume" },
      { "<leader>s.", desc = '[S]earch Recent Files ("." for repeat)' },
      { "<leader><leader>", desc = "[ ] Find existing buffers" },
      { "<leader>/", desc = "[/] Fuzzily search in current buffer" },
      { "<leader>s/", desc = "[S]earch [/] in Open Files" },
      { "<leader>sn", desc = "[S]earch [N]eovim files" },
    },
    dependencies = {
      { "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
    },
    config = function()
      local fzf = require("fzf-lua")
      fzf.setup({ "default-title" })
      fzf.register_ui_select()

      vim.keymap.set("n", "<leader>sh", fzf.helptags, { desc = "[S]earch [H]elp" })
      vim.keymap.set("n", "<leader>sk", fzf.keymaps, { desc = "[S]earch [K]eymaps" })
      vim.keymap.set("n", "<leader>sf", fzf.files, { desc = "[S]earch [F]iles" })
      vim.keymap.set("n", "<leader>ss", fzf.builtin, { desc = "[S]earch [S]elect" })
      vim.keymap.set("n", "<leader>sw", fzf.grep_cword, { desc = "[S]earch current [W]ord" })
      vim.keymap.set("n", "<leader>sg", fzf.live_grep, { desc = "[S]earch by [G]rep" })
      vim.keymap.set("n", "<leader>sd", fzf.diagnostics_workspace, { desc = "[S]earch [D]iagnostics" })
      vim.keymap.set("n", "<leader>sr", fzf.resume, { desc = "[S]earch [R]esume" })
      vim.keymap.set("n", "<leader>s.", fzf.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set("n", "<leader><leader>", fzf.buffers, { desc = "[ ] Find existing buffers" })

      vim.keymap.set("n", "<leader>/", fzf.lgrep_curbuf, { desc = "[/] Fuzzily search in current buffer" })

      vim.keymap.set("n", "<leader>s/", function()
        local paths = {}
        for _, b in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_loaded(b) and vim.bo[b].buflisted then
            local n = vim.api.nvim_buf_get_name(b)
            if n ~= "" and vim.uv.fs_stat(n) then
              table.insert(paths, vim.fn.shellescape(n))
            end
          end
        end
        fzf.live_grep({
          cmd = "rg --column --line-number --no-heading --color=always --smart-case -- %s " .. table.concat(paths, " "),
          prompt = "Live Grep (open files)> ",
        })
      end, { desc = "[S]earch [/] in Open Files" })

      vim.keymap.set("n", "<leader>sn", function()
        fzf.files({ cwd = vim.fn.stdpath("config") })
      end, { desc = "[S]earch [N]eovim files" })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    event = { "FileType" },
    dependencies = {
      "saghen/blink.cmp",
    },
    config = function()
      vim.env.RUSTC_BOOTSTRAP = "1"

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or "n"
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          map("gd", require("fzf-lua").lsp_definitions, "[G]oto [D]efinition")
          map("gr", require("fzf-lua").lsp_references, "[G]oto [R]eferences")
          map("gI", require("fzf-lua").lsp_implementations, "[G]oto [I]mplementation")
          map("<leader>D", require("fzf-lua").lsp_typedefs, "Type [D]efinition")
          map("<leader>ds", require("fzf-lua").lsp_document_symbols, "[D]ocument [S]ymbols")
          map("<leader>ws", require("fzf-lua").lsp_live_workspace_symbols, "[W]orkspace [S]ymbols")
          map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
          map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })

          map("<leader>co", function()
            vim.lsp.buf.code_action({
              context = { only = { "source.organizeImports" } },
              apply = true,
            })
          end, "[C]ode [O]rganize imports")

          map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
          map("<C-k>", vim.lsp.buf.signature_help, "Signature Help", "i")

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if
            client
            and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, { bufnr = event.buf })
          then
            local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd("LspDetach", {
              group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
              end,
            })
          end

          if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map("<leader>th", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
            end, "[T]oggle Inlay [H]ints")
          end
        end,
      })

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend("force", capabilities, require("blink.cmp").get_lsp_capabilities())

      local servers = {
        gopls = {
          cmd = { "nix", "run", "nixpkgs#gopls" },
        },
        basedpyright = {
          cmd = { "nix", "shell", "nixpkgs#basedpyright", "--command", "basedpyright-langserver", "--stdio" },
        },
        rust_analyzer = {
          cmd = { "nix", "shell", "nixpkgs#rust-analyzer", "--command", "rust-analyzer" },
          cmd_env = {
            CARGO_TARGET_DIR = "target/analyzer",
          },
        },
        zls = {
          cmd = { "nix", "run", "nixpkgs#zls" },
        },
        elixirls = {
          cmd = { "nix", "run", "nixpkgs#elixir-ls" },
        },
        ts_ls = {
          cmd = { "nix", "run", "nixpkgs#typescript-language-server", "--", "--stdio" },
        },
        svelte = {
          cmd = { "nix", "run", "nixpkgs#svelte-language-server", "--", "--stdio" },
        },
        nil_ls = {
          cmd = { "nix", "run", "nixpkgs#nil" },
        },
        yamlls = {
          cmd = { "nix", "run", "nixpkgs#yaml-language-server", "--", "--stdio" },
        },
        jsonls = {
          cmd = { "nix", "run", "nixpkgs#vscode-json-languageserver", "--", "--stdio" },
        },
      }

      for name, server in pairs(servers) do
        server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
        vim.lsp.config(name, server)
        vim.lsp.enable(name)
      end

      -- vim.lsp.enable's FileType autocmd registers after the triggering
      -- buffer's FileType already fired; re-fire once for it.
      local cur = vim.api.nvim_get_current_buf()
      if vim.bo[cur].filetype ~= "" then
        vim.api.nvim_exec_autocmds("FileType", { buffer = cur })
      end
    end,
  },
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {
      notification = {
        window = {
          winblend = 0,
        },
      },
    },
  },

  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>f",
        function()
          vim.lsp.buf.code_action({
            context = { only = { "source.organizeImports" } },
            apply = true,
          })
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        mode = "",
        desc = "[F]ormat buffer",
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        local disable_filetypes = { c = true, cpp = true }
        return {
          timeout_ms = 2000,
          lsp_format = disable_filetypes[vim.bo[bufnr].filetype] and "never" or "fallback",
        }
      end,
      formatters_by_ft = {},
    },
  },

  {
    "saghen/blink.cmp",
    event = "InsertEnter",
    version = "1.*",
    opts = {
      keymap = {
        preset = "none",
        ["<C-n>"] = { "select_next", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback" },
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
        ["<CR>"] = { "accept", "fallback" },
        ["<C-e>"] = { "hide", "fallback" },
        ["<S-Space>"] = { "show", "fallback" },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      completion = {
        accept = { auto_brackets = { enabled = true } },
      },
    },
  },

  {
    "stevearc/oil.nvim",
    cmd = "Oil",
    keys = {
      { "<leader>e", "<CMD>Oil<CR>", desc = "Open file explorer" },
    },
    opts = { keymaps = { ["<leader>e"] = "actions.close" } },
    dependencies = {
      { "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
    },
  },

  {
    "neovim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    dependencies = {
      "neovim-treesitter/treesitter-parser-registry",
    },
    config = function(_, opts)
      local treesitter = require("nvim-treesitter")
      treesitter.setup(opts)

      local installed = treesitter.get_installed()
      vim.opt.foldmethod = "expr"
      vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
      local function start(buf)
        local ft = vim.bo[buf].filetype
        if ft == "" then
          return
        end
        local lang = vim.treesitter.language.get_lang(ft)
        if lang and vim.tbl_contains(installed, lang) then
          pcall(vim.treesitter.start, buf)
          vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          start(args.buf)
        end,
      })
      start(vim.api.nvim_get_current_buf())
    end,
  },

  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      fast_wrap = {},
      disable_filetype = { "fzf", "vim" },
    },
  },

  {
    "mg979/vim-visual-multi",
    keys = { { "<C-n>" }, { "<C-S-n>" } },
    init = function()
      vim.g.VM_theme = "codedark"
    end,
  },
  {
    "folke/flash.nvim",
    -- stylua: ignore
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },
  {
    "voldikss/vim-floaterm",
    -- stylua: ignore
    keys = {
      { "<C-t>", "<CMD>FloatermToggle<CR>", desc = "Toggle floaterm" },
      { "<C-n>", "<C-\\><C-N>:FloatermNew<CR>", mode = "t", desc = "Create a new floaterm window" },
      { "<C-h>", "<C-\\><C-N><C-w>h", mode = "t", desc = "Move focus to the left window" },
      { "<C-l>", "<C-\\><C-N><C-w>l", mode = "t", desc = "Move focus to the right window" },
      { "<C-k>", "<C-\\><C-N>:FloatermPrev<CR>", mode = "t", desc = "Goto previous floaterm window" },
      { "<C-j>", "<C-\\><C-N>:FloatermNext<CR>", mode = "t", desc = "Goto next floaterm window" },
      { "<C-t>", "<C-\\><C-N>:FloatermToggle<CR>", mode = "t", desc = "Toggle floaterm" },
      { "<C-d>", "<C-\\><C-N>:FloatermKill<CR>", mode = "t", desc = "Kill floaterm" },
    },
    config = function()
      vim.g.floaterm_wintype = "float"
      vim.g.floaterm_position = "bottom"
      vim.g.floaterm_autoinsert = true
      vim.g.floaterm_width = 0.98
      vim.g.floaterm_height = 0.3
      vim.g.floaterm_title = (
        vim.g.have_nerd_font and "─────  Terminal [$1|$2] " or "───── Terminal [$1|$2] "
      )
      vim.cmd.hi("FloatermBorder guibg=none")
    end,
  },

  { import = "plugins" },
}, {
  rocks = { enabled = false },
  ui = { border = "single" },
  performance = {
    cache = { enabled = true },
    reset_packpath = true,
    rtp = {
      disabled_plugins = {
        "2html_plugin",
        "tohtml",
        "getscript",
        "getscriptPlugin",
        "gzip",
        "logipat",
        "netrw",
        "netrwPlugin",
        "netrwSettings",
        "netrwFileHandlers",
        "matchit",
        "tar",
        "tarPlugin",
        "rrhelper",
        "spellfile_plugin",
        "vimball",
        "vimballPlugin",
        "zip",
        "zipPlugin",
        "tutor",
        "rplugin",
        "synmenu",
        "optwin",
        "compiler",
        "bugreport",
      },
    },
  },
})
