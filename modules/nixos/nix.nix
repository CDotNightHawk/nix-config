# Inspired by https://codeberg.org/ihaveahax/nix-config
{
  config,
  lib,
  pkgs,
  me,
  r,
  inputs,
  ...
}:

let
  nixpkgs-config-local = import (r.libs + /nixpkgs-config.nix) { inherit pkgs inputs; };
in
{
  # seems nixpkgs already sets NIXPKGS_CONFIG to this path
  environment = {
    etc."nix/nixpkgs-config.nix".text = nixpkgs-config-local;
  };

  nix.settings = {
    # needed for cachix and linux-builder
    # root is assumed to be here
    trusted-users = [ "${me}" ];
  };

  # Compatibility overlays: nixvim 's docs build still references some
  # nixpkgs packages that have been renamed/removed. Map the legacy
  # names to their current replacements so eval doesn't choke.
  nixpkgs.overlays = [
    (final: prev: {
      mdbook-linkcheck = final.mdbook-linkcheck2;
    })
  ];
}
