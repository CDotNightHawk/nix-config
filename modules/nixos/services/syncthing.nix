# Inspired by https://codeberg.org/ihaveahax/nix-config
{
  config,
  lib,
  pkgs,
  me,
  ...
}:

{
  services.syncthing = {
    enable = true;
    user = me;
    dataDir = config.users.users.${me}.home;
    openDefaultPorts = true;
  };

  networking.firewall.allowedTCPPorts = [ 8384 ];

  users.users.${me}.extraGroups = [ "syncthing" ];
}
