# Spicetify — declarative Spotify customisation.
#
# Wraps spicetify-nix's home-manager module to produce a "spiced"
# Spotify package with the extensions listed below baked in.  Adding
# or removing extensions is a one-line change; run
#   nixos-rebuild switch --flake .#<host>
# and relaunch Spotify.
{
  lib,
  pkgs,
  inputs,
  ...
}:

let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
in
{
  imports = [ inputs.spicetify-nix.homeManagerModules.default ];

  programs.spicetify = {
    enable = true;

    enabledExtensions = with spicePkgs.extensions; [
      adblockify
    ];
  };
}
