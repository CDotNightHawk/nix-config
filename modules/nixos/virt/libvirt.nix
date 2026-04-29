# Inspired by https://codeberg.org/ihaveahax/nix-config
{
  config,
  lib,
  pkgs,
  me,
  ...
}:

{
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      #package = pkgs.qemu_kvm; # only do host architecture
      swtpm.enable = true;
    };
  };

  users.users.${me}.extraGroups = [
    "libvirtd"
    "qemu-libvirtd"
  ];

  environment = {
    systemPackages = [ config.virtualisation.libvirtd.qemu.package ];
  };
}
