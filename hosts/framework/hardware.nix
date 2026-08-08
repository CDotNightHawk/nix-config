# Framework 13 AMD-specific hardware tweaks that are NOT safe to put
# into the auto-generated hardware-configuration.nix (which is overwritten
# by nixos-generate-config).
_:

{
  # NOTE: do not declare `fileSystems.<mp>` here as a partial override
  # ({ options = ...; } only). nixpkgs 26.05 made `fsType` mandatory
  # (no default), so any partial override risks colliding with module
  # merging on stricter evaluators. Put all fileSystems fields together
  # in hardware-configuration.nix.

  # AMD microcode updates come via linux-firmware; this is already
  # defaulted via hardware.enableRedistributableFirmware, but pinning
  # it here documents the intent.
  hardware.cpu.amd.updateMicrocode = true;
}
