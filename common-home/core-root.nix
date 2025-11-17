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
    ./core.nix
  ];

  home.packages = with pkgs; [
    htop      # Interactive process viewer
    ncdu      # Disk usage analyzer
    tcpdump   # Network packet analyzer
    lsof      # List open files
  ];

  programs = {
    ssh.enable = lib.mkForce false;
    git.enable = lib.mkForce false;
    yt-dlp.enable = lib.mkForce false;

    zsh = {
      # Safety aliases for file operations
      shellAliases = {
        rm = "rm -i";
        cp = "cp -i";
        mv = "mv -i";
      };

      # distinct red prompt for root to prevent accidents
      initExtra = ''
        # Set local color to Red
        export LOCALCOLOR=$'%{\e[1;31m%}'
        
        # Manually enforce the prompt format with the new color
        # (Overrides the default green/stock setup from shared-zsh-settings.nix)
        PS1=$'[''${LOCALCOLOR}%n@%m%{\e[0m%} %d]\n# '
      '';
    };
  };
}
