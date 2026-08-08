# Placeholder hardware configuration for the workstation host.
# Generate the real configuration from the installer with:
#   sudo nixos-generate-config --no-filesystems --root /mnt
# Replace this file with `/mnt/etc/nixos/hardware-configuration.nix`.
# Filesystems are omitted because disko owns those declarations.
{
  config,
  lib,
  modulesPath,
  ...
}:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # Intel i9 (11th generation, Rocket Lake).
  boot.kernelModules = [ "kvm-intel" ];
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usbhid"
    "sd_mod"
  ];

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Keeps the flake evaluable until generated hardware data is committed.
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
