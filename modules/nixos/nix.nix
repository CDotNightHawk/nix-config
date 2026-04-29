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

      # Lix's `installCheckPhase` runs the upstream functional2 test
      # suite, which uses `unshare(CLONE_NEWNS)` to swap mount
      # propagation. That requires CAP_SYS_ADMIN, which is dropped in
      # GitHub Actions runners (and other sandboxed CI environments)
      # — the test errors with:
      #   unshare: cannot change root filesystem propagation: Permission denied
      # …and the lix derivation fails. We are not lix's CI; we don't
      # need to re-run their test suite when packaging it. Skip the
      # install check so building lix is hermetic to its inputs.
      lix = prev.lix.overrideAttrs (_: {
        doInstallCheck = false;
      });
    })
  ];
}
