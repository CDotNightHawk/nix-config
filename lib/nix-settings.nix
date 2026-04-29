{
  config,
  lib,
  pkgs,
  ...
}:

# shared across NixOS, nix-darwin, and Home Manager
{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix.package = pkgs.lix;

  nix.registry = {
    jovian = {
      from = {
        id = "jovian";
        type = "indirect";
      };
      to = {
        owner = "Jovian-Experiments";
        repo = "Jovian-NixOS";
        type = "github";
      };
    };
    nixos-apple-silicon = {
      from = {
        id = "nixos-apple-silicon";
        type = "indirect";
      };
      to = {
        owner = "tpwrules";
        repo = "nixos-apple-silicon";
        type = "github";
      };
    };
    night-nur = {
      from = {
        id = "night-nur";
        type = "indirect";
      };
      to = {
        owner = "CDotNightHawk";
        repo = "nur-packages";
        type = "github";
      };
    };
    pyctr = {
      from = {
        id = "pyctr";
        type = "indirect";
      };
      to = {
        owner = "ihaveamac";
        repo = "pyctr";
        type = "github";
      };
    };
  };
  nix.settings = {
    # this was originally set by nix-darwin
    bash-prompt-prefix = "(nix:$name)\\040";
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    extra-nix-path = [
      "nixpkgs=flake:nixpkgs"
      "nur=flake:nur"
      "night-nur=flake:night-nur"
    ];
    # mkForce is used here because on a home-manager setup, not including cache.nixos.org seems to cause nix to ignore it
    # but on NixOS (and maybe nix-darwin), it is already included, so adding it would normally include it twice
    # so i use mkForce here to make it only list the ones i want
    substituters = lib.mkForce [
      "https://cache.nixos.org"
      "https://nighthawk.cachix.org"
      # Without cache.lix.systems the Nix daemon has to compile lix
      # itself (~10 min of clang/ninja) on every fresh install.
      "https://cache.lix.systems"
    ]; # "https://attic.nanofox.dev/cdotnighthawk"
    trusted-public-keys = lib.mkForce [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nighthawk.cachix.org-1:+Ppa/mjYFZFhMz95oSQNRJo+J9koACCy/4GtcautuYc="
      "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
    ];
    # this will be overridden in home-manager
    netrc-file = "/etc/nix/netrc";
    use-xdg-base-directories = true;
  };
}
