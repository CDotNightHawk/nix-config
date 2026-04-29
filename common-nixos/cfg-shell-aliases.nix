# Inspired by https://codeberg.org/ihaveahax/nix-config
{
  config,
  lib,
  pkgs,
  ...
}:

{
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "nrvl" ''
      exec nixos-rebuild -v -L "$@"
    '')
  ];
}
