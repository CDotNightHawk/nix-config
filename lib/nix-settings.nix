{
  lib,
  pkgs,
  inputs,
  ...
}:

{
  nixpkgs.config.allowUnfree = true;
  nix = {
    package = pkgs.lix;
    registry.nixpkgs.flake = inputs.nixos-unstable;
    nixPath = [ "nixpkgs=flake:nixpkgs" ];
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      allowed-users = [ "@users" ];
      trusted-users = [ "root" ];
      builders-use-substitutes = true;
      connect-timeout = 5;
      download-attempts = 3;
      fallback = true;
      log-lines = 25;
      require-sigs = true;
      sandbox = true;
      use-xdg-base-directories = true;
      substituters = lib.mkForce [
        "https://cache.nixos.org"
        "https://nighthawk.cachix.org"
        "https://cache.lix.systems"
      ];
      trusted-public-keys = lib.mkForce [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nighthawk.cachix.org-1:+Ppa/mjYFZFhMz95oSQNRJo+J9koACCy/4GtcautuYc="
        "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
      ];
    };
  };
}
