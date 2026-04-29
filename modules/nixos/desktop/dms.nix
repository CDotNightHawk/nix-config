# DankMaterialShell — system-side bits.
#
# DMS (https://danklinux.com) is a QuickShell-based status bar +
# launcher + lockscreen + control center for niri. It needs the dgop
# system-monitoring helper installed system-wide, which the upstream
# NixOS module handles for us.
#
# Per-user knobs live in `modules/home/desktop/niri-dms.nix`.
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.dms.nixosModules.dank-material-shell
  ];

  programs.dank-material-shell = {
    enable = true;
    enableSystemMonitoring = true;
    # `dgop` lives in nixpkgs >= 26.05. Our pinned `nixos-unstable`
    # is older than that, so pull the package from the dgop flake.
    dgop.package = inputs.dgop.packages.${pkgs.system}.default;
  };

  # DMS shows network/bluetooth/audio panels — make sure their backends
  # are present so the panel buttons actually do something.
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
}
