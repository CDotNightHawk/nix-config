# Generic UEFI server. Replace hardware.nix with generated hardware settings
# before installing on physical hardware.
{
  lib,
  me,
  r,
  ...
}:

{
  imports = [
    (r.profilesNixos + /server.nix)
    ./hardware.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    systemd-boot.configurationLimit = 10;
    efi.canTouchEfiVariables = true;
  };

  networking = {
    hostName = "server";
    networkmanager.enable = false;
    useDHCP = lib.mkDefault true;
    useNetworkd = true;
  };

  systemd.network.wait-online.anyInterface = true;

  users = {
    mutableUsers = false;
    users.${me}.openssh.authorizedKeys.keyFiles = [ (r.libs + /keys/id_rsa.pub) ];
  };

  system.stateVersion = "24.05";
}
