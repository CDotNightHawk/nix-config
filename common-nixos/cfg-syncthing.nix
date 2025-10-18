# Inspired by https://codeberg.org/ihaveahax/nix-config
{ config, pkgs, ... }:

{
  services.syncthing = {
    enable = true;
    user = "nighthawk";
    dataDir = "/home/nighthawk";
    openDefaultPorts = true;
  };

  networking.firewall.allowedTCPPorts = [ 8384 ];

  # maybe this is a bad idea?
  users.users.nighthawk.extraGroups = [ "syncthing" ];
}
