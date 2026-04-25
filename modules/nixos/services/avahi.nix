# Inspired by https://codeberg.org/ihaveahax/nix-config
{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
