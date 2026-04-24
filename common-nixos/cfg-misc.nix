# Inspired by https://codeberg.org/ihaveahax/nix-config
{
  config,
  lib,
  pkgs,
  me,
  ...
}:

{
  # due to networkmanager-openconnect causing webkitgtk to build with an extreme build time
  networking.networkmanager.plugins = lib.mkForce [ ];

  # `system.rebuild.enableNg` was removed; nixos-rebuild-ng is the
  # default now.

  environment.variables.MANPAGER = "nvim +Man!";
}
