# Placeholder hardware-configuration.nix for the workstation host.
#
# Once you boot the install ISO, run:
#   sudo nixos-generate-config --no-filesystems --root /mnt
# and replace this file with the generated
# `/mnt/etc/nixos/hardware-configuration.nix`.
#
# We use `--no-filesystems` because filesystems are declared by disko
# (see ./disko.nix); generating them again would duplicate the
# definitions and `nixos-rebuild` would refuse to evaluate.
#
# Until the real file is committed, this stub keeps the flake
# evaluable.
{
  config,
  lib,
  modulesPath,
  ...
}:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # Intel i9 (11th gen / Rocket Lake) — KVM intel.
  boot.kernelModules = [ "kvm-intel" ];
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usbhid"
    "sd_mod"
  ];

  # CPU is Intel.
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # The platform is x86_64-linux; we keep this here so even with the
  # stub hardware-configuration.nix you can `nix flake check`.
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
