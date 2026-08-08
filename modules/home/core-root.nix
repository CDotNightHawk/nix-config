{
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./core.nix
  ];

  home.packages = with pkgs; [
    htop
    lsof
    ncdu
    tcpdump
  ];

  programs = {
    ssh.enable = lib.mkForce false;
    git.enable = lib.mkForce false;
    yt-dlp.enable = lib.mkForce false;

    zsh = {
      shellAliases = {
        rm = "rm -i";
        cp = "cp -i";
        mv = "mv -i";
      };

      initContent = ''
        export LOCALCOLOR=$'%{\e[1;31m%}'
        PS1=$'[''${LOCALCOLOR}%n@%m%{\e[0m%} %d]\n# '
      '';
    };
  };
}
