# Per-host kernel selection.
#
# Each host should set `nighthawk.kernel = "<flavor>"` in its own
# configuration. The default is "lts" (boot.kernelPackages =
# linuxPackages_6_12) for stability; new hardware that needs a recent
# kernel (e.g. AMD RDNA4 GPUs, latest Intel SoCs) should pick "latest"
# or "zen".
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.nighthawk.kernel;

  flavors = {
    lts = pkgs.linuxPackages_6_12;
    latest = pkgs.linuxPackages_latest;
    zen = pkgs.linuxPackages_zen;
    hardened = pkgs.linuxPackages_hardened;
  };
in
{
  options.nighthawk.kernel = lib.mkOption {
    type = lib.types.enum (lib.attrNames flavors);
    default = "lts";
    example = "latest";
    description = ''
      Which kernel package set to install on this host. See
      `flavors` in modules/nixos/kernel.nix for the mapping.
    '';
  };

  config.boot.kernelPackages = flavors.${cfg};
}
