# Framework 13 AMD-specific hardware tweaks that are NOT safe to put
# into the auto-generated hardware-configuration.nix (which is overwritten
# by nixos-generate-config).
{
  config,
  lib,
  pkgs,
  ...
}:

{
  # BTRFS on NVMe: zstd compression + noatime is the current community
  # consensus for Framework 13 laptops. Reduces writes and gives a
  # measurable space win with negligible CPU cost on Zen4.
  fileSystems."/" = {
    options = lib.mkForce [
      "subvol=@"
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/home" = {
    options = lib.mkForce [
      "compress=zstd"
      "noatime"
    ];
  };

  # AMD microcode updates come via linux-firmware; this is already
  # defaulted via hardware.enableRedistributableFirmware, but pinning
  # it here documents the intent.
  hardware.cpu.amd.updateMicrocode = true;
}
