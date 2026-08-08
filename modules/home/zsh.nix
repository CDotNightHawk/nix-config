# Inspired by https://codeberg.org/ihaveahax/nix-config
{
  config,
  lib,
  pkgs,
  r,
  ...
}:

let
  zshShared = pkgs.callPackage (r.libs + /zsh-shared.nix) { inherit config; };
in
{
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    history = {
      expireDuplicatesFirst = true;
      extended = true;
      append = true;
      path = "${config.home.homeDirectory}/.local/state/zsh_history";
    };
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      nv = "nvim";
      hactool = "hactool --disablekeywarns";
      amke = "make";
      mkae = "make";
      nvl = "nix -v -L";
      nixgc = "nix-env --delete-generations --profile ${config.xdg.stateHome}/nix/profiles/home-manager old; sudo ${config.nix.package}/bin/nix-collect-garbage -d;";
      nano = "vim";
      kwrite = "kate";
      ls = "eza";
      encrypt = "sops --encrypt --in-place";
      sudo = "doas";
    };
    oh-my-zsh = {
      enable = true;
      inherit (zshShared.ohMyZsh) plugins;
      extraConfig = zshShared.ohMyZsh.config;
    };
    envExtra = zshShared.shellInit;
    initContent = lib.concatStringsSep "\n" [
      (lib.optionalString (
        zshShared.options != [ ]
      ) "setopt ${builtins.concatStringsSep " " zshShared.options}")
      zshShared.interactiveShellInit
    ];
    profileExtra = zshShared.loginShellInit;
  };

  programs.nix-your-shell.enable = true;
}
