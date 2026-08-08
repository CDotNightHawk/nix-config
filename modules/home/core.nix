{
  pkgs,
  ...
}:

{
  imports = [
    ./git.nix
    ./ssh.nix
    ./vifm.nix
    ./xdg.nix
    ./zsh.nix
  ];

  programs = {
    bat = {
      enable = true;
      extraPackages = with pkgs.bat-extras; [
        batdiff
        batgrep
        batman
        batwatch
      ];
    };
    eza = {
      enable = true;
      git = true;
      icons = "auto";
      extraOptions = [
        "--group-directories-first"
        "--group"
        "--header"
      ];
    };
    nix-index = {
      enable = true;
      enableZshIntegration = true;
    };
    ripgrep.enable = true;
    tmux.enable = true;
    yt-dlp.enable = true;
  };

  home = {
    packages = with pkgs; [
      cachix
      colordiff
      curl
      magic-wormhole-rs
      nix-tree
      pv
      rsync
      s3cmd
      tree
      wget
      xz
      zstd
    ];
    sessionVariables.MANPAGER = "nvim +Man!";
    stateVersion = "24.05";
  };
}
