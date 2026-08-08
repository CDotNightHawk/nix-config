{
  config,
  me,
  ...
}:

{
  virtualisation.libvirtd = {
    enable = true;
    qemu.swtpm.enable = true;
  };

  users.users.${me}.extraGroups = [
    "libvirtd"
    "qemu-libvirtd"
  ];

  environment.systemPackages = [ config.virtualisation.libvirtd.qemu.package ];
}
