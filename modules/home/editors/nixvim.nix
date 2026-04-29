# NixVim — declarative Neovim. Replaces the old hand-rolled
# extras/neovim-config.{vim,lua} setup with something that fails at
# `nix flake check` time when a plugin is misconfigured.
#
# Goals: a sysadmin/devops/coding-friendly nvim with LSP, treesitter,
# fuzzy finder, file tree, git integration, and the languages NightHawk
# actually touches (Nix, Python, Go, TypeScript, Bash, Rust, YAML/JSON,
# Terraform/HCL, Lua).
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [ inputs.nixvim.homeModules.nixvim ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    luaLoader.enable = true;

    colorschemes.catppuccin = {
      enable = true;
      settings.flavour = "mocha";
    };

    opts = {
      number = true;
      relativenumber = true;
      shiftwidth = 2;
      tabstop = 2;
      expandtab = true;
      smartindent = true;
      wrap = false;
      ignorecase = true;
      smartcase = true;
      termguicolors = true;
      signcolumn = "yes";
      undofile = true;
      cursorline = true;
      scrolloff = 8;
      updatetime = 250;
      timeoutlen = 400;
      completeopt = [
        "menu"
        "menuone"
        "noselect"
      ];
      clipboard = "unnamedplus";
    };

    globals = {
      mapleader = " ";
      maplocalleader = " ";
    };

    plugins = {
      # --- UI ----------------------------------------------------------
      lualine.enable = true;
      bufferline.enable = true;
      web-devicons.enable = true;
      which-key.enable = true;
      todo-comments.enable = true;
      gitsigns.enable = true;
      indent-blankline.enable = true;

      # --- File tree / pickers ----------------------------------------
      neo-tree = {
        enable = true;
        settings.close_if_last_window = true;
      };
      telescope = {
        enable = true;
        extensions = {
          fzf-native.enable = true;
          ui-select.enable = true;
        };
        keymaps = {
          "<leader>ff" = "find_files";
          "<leader>fg" = "live_grep";
          "<leader>fb" = "buffers";
          "<leader>fh" = "help_tags";
          "<leader>fr" = "oldfiles";
          "<leader>fd" = "diagnostics";
        };
      };

      # --- LSP / completion -------------------------------------------
      lsp = {
        enable = true;
        servers = {
          # Nix
          nil_ls.enable = true;
          # Python
          pyright.enable = true;
          ruff.enable = true;
          # Go
          gopls.enable = true;
          # TypeScript / JavaScript
          ts_ls.enable = true;
          # Bash
          bashls.enable = true;
          # Rust
          rust_analyzer = {
            enable = true;
            installCargo = false;
            installRustc = false;
          };
          # YAML / JSON
          yamlls.enable = true;
          jsonls.enable = true;
          # HCL / Terraform
          terraformls.enable = true;
          # Lua (for editing nvim/awesome configs)
          lua_ls.enable = true;
          # Docker
          dockerls.enable = true;
          # Helm
          helm_ls.enable = true;
        };
        keymaps.lspBuf = {
          gd = "definition";
          gD = "declaration";
          gi = "implementation";
          gr = "references";
          K = "hover";
          "<leader>ca" = "code_action";
          "<leader>rn" = "rename";
        };
      };

      cmp = {
        enable = true;
        autoEnableSources = true;
        settings = {
          sources = [
            { name = "nvim_lsp"; }
            { name = "luasnip"; }
            { name = "buffer"; }
            { name = "path"; }
          ];
          mapping = {
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-d>" = "cmp.mapping.scroll_docs(-4)";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<Tab>" = "cmp.mapping.select_next_item()";
            "<S-Tab>" = "cmp.mapping.select_prev_item()";
          };
        };
      };
      luasnip.enable = true;

      # --- Treesitter --------------------------------------------------
      treesitter = {
        enable = true;
        settings = {
          highlight.enable = true;
          indent.enable = true;
        };
      };
      treesitter-context.enable = true;

      # --- Formatting / lint ------------------------------------------
      conform-nvim = {
        enable = true;
        settings = {
          format_on_save = {
            timeout_ms = 1500;
            lsp_format = "fallback";
          };
          formatters_by_ft = {
            nix = [ "nixfmt" ];
            python = [
              "ruff_fix"
              "ruff_format"
            ];
            go = [ "gofmt" ];
            terraform = [ "terraform_fmt" ];
            yaml = [ "yamlfmt" ];
            json = [ "prettierd" ];
            javascript = [ "prettierd" ];
            typescript = [ "prettierd" ];
            sh = [ "shfmt" ];
            lua = [ "stylua" ];
          };
        };
      };

      # --- Git ---------------------------------------------------------
      fugitive.enable = true;
      diffview.enable = true;

      # --- DAP (debug) -------------------------------------------------
      dap.enable = true;
      dap-ui.enable = true;
      dap-virtual-text.enable = true;

      # --- Misc terminal-mode things sysadmins like ------------------
      toggleterm = {
        enable = true;
        settings = {
          direction = "float";
          open_mapping = "[[<C-\\>]]";
        };
      };

      # Markdown preview without leaving nvim
      markdown-preview.enable = true;

      # NeoGit for staged-commit driven workflow
      neogit.enable = true;
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>e";
        action = "<cmd>Neotree toggle<CR>";
        options.desc = "Toggle file tree";
      }
      {
        mode = "n";
        key = "<leader>w";
        action = "<cmd>w<CR>";
        options.desc = "Save";
      }
      {
        mode = "n";
        key = "<leader>q";
        action = "<cmd>q<CR>";
        options.desc = "Quit";
      }
      {
        mode = "n";
        key = "<leader>gs";
        action = "<cmd>Neogit<CR>";
        options.desc = "Neogit";
      }
      {
        mode = "n";
        key = "<C-h>";
        action = "<C-w>h";
      }
      {
        mode = "n";
        key = "<C-j>";
        action = "<C-w>j";
      }
      {
        mode = "n";
        key = "<C-k>";
        action = "<C-w>k";
      }
      {
        mode = "n";
        key = "<C-l>";
        action = "<C-w>l";
      }
    ];

    extraPackages = with pkgs; [
      # Formatters / linters that conform-nvim shells out to.
      nixfmt
      ruff
      shfmt
      stylua
      yamlfmt
      prettier
      gofumpt
    ];
  };
}
