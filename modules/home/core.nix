# Inspired by https://codeberg.org/ihaveahax/nix-config
{
  config,
  lib,
  pkgs,
  my-inputs,
  ...
}:

{
  imports = [
    # Neovim is provided by ./editors/nixvim.nix, imported per host.
    ./zsh.nix
    ./git.nix
    ./ssh.nix
    ./vifm.nix
    ./xdg.nix
  ];

  programs = {
    eza = {
      enable = true;
      git = true;
      icons = "auto";
      extraOptions = [
        "--group-directories-first"
        "--header"
        "--group"
      ];
    };
    bat = {
      enable = true;
      extraPackages = with pkgs.bat-extras; [
        batdiff
        batman
        batgrep
        batwatch
      ];
    };
    nix-index = {
      enable = true;
      enableZshIntegration = true;
    };
    ripgrep.enable = true;
    yt-dlp = {
      enable = true;
    };
    tmux.enable = true;
  };

  home.packages = with pkgs; [
    pv
    wget
    xz
    tree
    curl
    s3cmd
    zstd
    colordiff
    gist
    # error in a test, i think
    #magic-wormhole
    magic-wormhole-rs
    cachix
    nix-tree
    rsync
  ];

  home.sessionVariables = with config.xdg; {
    # https://www.reddit.com/r/archlinux/comments/1fpk3p0/most_useful_package/lp2dpu1/
    MANPAGER = "nvim +Man!";
  };

  # Note: allowUnfree is set once at the system level via
  # lib/nix-settings.nix.

  home.stateVersion = "24.05"; # Please read the comment before changing.
}
