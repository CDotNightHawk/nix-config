# /etc/nixos/users/nighthawk/home.nix
{ config, pkgs, inputs, ... }:
{
  # Basic user info
  home.username = "nighthawk";
  home.homeDirectory = "/home/nighthawk";
  
  home.stateVersion = "25.05";
  
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];
  
  sops.defaultSopsFile = ../../framework/secrets/keys/git/github.yaml;

  # 2. Point sops to your personal age key
  sops.age.keyFile = "/home/nighthawk/.config/sops/age/keys.txt";

  # 3. Define the secret and its destination
  sops.secrets.github_ssh_key = {
    # The name must match the key in your github.yaml file
    path = "${config.home.homeDirectory}/.ssh/id_github";
    mode = "0400"; # Restrictive permissions for a private key
  };
  
  sops.secrets.github_token = {
    format = "yaml";
    # can be also set per secret
    sopsFile = ../../framework/secrets/keys/git/github.yaml;
  };

  # 4. Configure SSH to use the new key
  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host github.com
        User git
        IdentityFile ${config.home.homeDirectory}/.ssh/id_github
        IdentitiesOnly yes
    '';
  };

  # Your personal packages. I moved all the GUI apps and user-specific
  # tools from your old config here.
  home.packages = with pkgs; [
    # From users.packages
    kdePackages.kate

    # From systemPackages that are better here
    ungoogled-chromium
    wezterm
    vesktop
    python314
    krita
    distrobox
    nerd-fonts.fira-code
    ripgrep
    lazygit
    thonny
    arduino-ide
    nicotine-plus
    firefox
    libreoffice-qt
    hunspell
    hunspellDicts.uk_UA
    hunspellDicts.th_TH
    (prismlauncher.override {
      # Add binary required by some mod
      additionalPrograms = [ ffmpeg ];
    })
  ];

  # Declaratively configure user programs
  programs.zsh.enable = true; # Manages Zsh settings for your user
  programs.git.enable = true;  # We can configure git here later

  programs.wezterm = {
  enable = true;
  extraConfig = ''
    local wezterm = require 'wezterm'
    local config = {}

    -- Set the Nerd Font
    config.font = wezterm.font 'FiraCode Nerd Font'

    -- Add other WezTerm settings here...
    config.color_scheme = 'Catppuccin Mocha'

    return config
  '';
  };

  # --- NvChad Configuration ---
  programs.neovim = {
    enable = true;
    defaultEditor = true; # Makes nvim the default for `EDITOR`
  };

  # Fetch NvChad source and link it to ~/.config/nvim
  # This is the declarative, Nix-native way to install it.
  xdg.configFile."nvim" = {
    source = pkgs.fetchFromGitHub {
      owner = "NvChad";
      repo = "NvChad";
      rev = "6fb5c313edc966f187c7483a16affaec0518b641";
      # New corresponding hash for that commit
      hash = "sha256-U81M3RFMP7jKirxj3ROCsyqTRXGCrtN6VsPrewlPSLI=";
    };
    recursive = true;
  };

  # Declaratively manage your custom NvChad config.
  # This file will be linked to ~/.config/nvim/lua/custom/chadrc.lua
  xdg.configFile."nvim/lua/custom/chadrc.lua".text = ''
  -- This is your custom configuration file.
  -- For examples, see: https://nvchad.com/docs/config/overriding_defaults

  ---@type ChadrcConfig
  local M = {}

  M.ui = {
    theme = 'onedark',
    hl_override = {
      Comment = { italic = true },
    },
  }

  -- Add this new section for Mason
  M.mason = {
    -- This list tells Mason which tools to automatically install.
    -- These will be installed the first time you open Neovim after rebuilding.
    ensure_installed = {
      -- C/C++ Language Server (for code completion, diagnostics, etc.)
      "clangd",

      -- Debug Adapter (for debugging with nvim-dap)
      "codelldb",

      -- C/C++ Code Formatter
      "clang-format",

      -- C/C++ Linter for static analysis
      "clang-tidy",
    },
  }

  M.plugins = {
    -- You can add custom plugins here if needed
  }

  return M
  '';

  # Let Home Manager manage itself
  programs.home-manager.enable = true;
}
