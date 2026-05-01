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
    ghostty
    pywalfox-native
    zed-editor
    vscode
    termius
    orca-slicer
    freecad
    feishin
    bitwarden-desktop
    wireguard-go
    wg-netmanager
  ];

  home.sessionVariables = with config.xdg; {
    # https://www.reddit.com/r/archlinux/comments/1fpk3p0/most_useful_package/lp2dpu1/
    MANPAGER = "nvim +Man!";
  };

  # VSCode / VSCodium / Electron apps built on top of libsecret
  # pick up the `password-store` setting from ~/.vscode/argv.json.
  # Without this they guess at the backend and sometimes fall back
  # to `basic text encoding` (plain-XOR), triggering the "weaker
  # encryption" prompt. Pinning `gnome-libsecret` makes VSCode
  # always route credentials through gnome-keyring, which we
  # enable system-wide in modules/nixos/desktop/keyring.nix.
  #
  # https://code.visualstudio.com/docs/configure/settings-sync#_troubleshooting-keychain-issues
  home.file.".vscode/argv.json".text = builtins.toJSON {
    password-store = "gnome-libsecret";
    # keep VSCode's own runtime args stable — no extra flags here.
    enable-crash-reporter = false;
  };

  # Note: allowUnfree is set once at the system level via
  # lib/nix-settings.nix.

  home.stateVersion = "24.05"; # Please read the comment before changing.
}
