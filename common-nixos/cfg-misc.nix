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

  system.rebuild.enableNg = true;

  environment.variables.MANPAGER = "nvim +Man!";
}
