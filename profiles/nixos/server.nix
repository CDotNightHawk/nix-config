{
  lib,
  r,
  ...
}:

{
  imports = with r; [
    ./base.nix
    (modulesNixos + /ssh.nix)
    (modulesNixos + /virt/incus.nix)
  ];

  nighthawk = {
    autoUpgrade.enable = true;
    incus.enable = true;
    kernel = lib.mkDefault "lts";
    ssh.enable = true;
  };

  nightpkg.packages.enableExtra = false;

  documentation = {
    doc.enable = false;
    info.enable = false;
    nixos.enable = false;
  };

  fonts.fontconfig.enable = false;

  systemd.coredump.extraConfig = ''
    Storage=none
    ProcessSizeMax=0
  '';
}
