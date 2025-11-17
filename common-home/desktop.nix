# Inspired by https://codeberg.org/ihaveahax/nix-config
{
  config,
  lib,
  pkgs,
  r,
  ...
}:

{
  home.packages =
    (with pkgs; [
      # Data & Text Processing
      dos2unix
      jo
      jq

      # Media & Images
      flac
      imagemagick
      qrencode

      # Cloud & Python Utilities
      doctl
      twine

      # Filesystem & Archives
      squashfsTools
      cdecrypt
    ])
    ++ lib.optionals (stdenv.isDarwin || (stdenv.isLinux && stdenv.isx86_64)) [
      pkgs.rar
    ]
    ++ (pkgs.callPackage (r.extras + /fonts.nix) { });

  # note: disabled in nix-darwin-alphinaud/home.nix
  # note: disabled in common-nixos/cfg-home-manager.nix
  fonts.fontconfig.enable = true;

  programs.pandoc.enable = true;

  programs.zsh = {
    oh-my-zsh.plugins = [ "doctl" ];
    initContent = ''
      ######################################################################
      # begin home/desktop.nix

      # end home/desktop.nix
    '';
  };

  xdg.configFile = {
    "ideavim/ideavimrc".text = ''
      # Match Neovim Settings
      set number
      set relativenumber
      set scrolloff=6
      set showmode

      # Plugins
      set surround

      # Mappings
      nmap <C-K> o<Esc>

      # Clipboard
      # https://stackoverflow.com/questions/27898407/intellij-idea-with-ideavim-cannot-copy-text-from-another-source
      set clipboard+=unnamed
    '';
  };
}
