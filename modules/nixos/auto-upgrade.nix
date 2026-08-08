{
  config,
  lib,
  ...
}:

let
  cfg = config.nighthawk.autoUpgrade;
in
{
  options.nighthawk.autoUpgrade = {
    enable = lib.mkEnableOption "automatic builds from the published flake";
    flake = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Flake URI to build. The published host configuration is used by default.";
    };
    dates = lib.mkOption {
      type = lib.types.str;
      default = "Sun *-*-* 04:00:00";
      description = "systemd calendar expression for upgrade builds.";
    };
  };

  config = lib.mkIf cfg.enable {
    system.autoUpgrade = {
      enable = true;
      flake =
        if cfg.flake == null then
          "github:CDotNightHawk/nix-config#${config.networking.hostName}"
        else
          cfg.flake;
      operation = "boot";
      flags = [
        "--refresh"
        "--print-build-logs"
      ];
      inherit (cfg) dates;
      randomizedDelaySec = "45min";
      allowReboot = false;
    };
  };
}
