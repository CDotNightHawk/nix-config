{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.nighthawk.desktopApps;
in
{
  options.nighthawk.desktopApps = {
    enable = lib.mkEnableOption "the essential graphical application set";
    cad.enable = lib.mkEnableOption "CAD and 3D-printing applications";
    minecraft.enable = lib.mkEnableOption "Prism Launcher";
    peerToPeer.enable = lib.mkEnableOption "peer-to-peer clients";
    remoteAccess.enable = lib.mkEnableOption "remote-access clients";
    teams.enable = lib.mkEnableOption "Microsoft Teams for Linux";
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      (with pkgs; [
        bitwarden-desktop
        easyeffects
        vscode
      ])
      ++ lib.optionals cfg.cad.enable (
        with pkgs;
        [
          freecad
          orca-slicer
        ]
      )
      ++ lib.optionals cfg.minecraft.enable [ pkgs.prismlauncher ]
      ++ lib.optionals cfg.peerToPeer.enable (
        with pkgs;
        [
          nicotine-plus
          transmission_4-gtk
        ]
      )
      ++ lib.optionals cfg.remoteAccess.enable (
        with pkgs;
        [
          rustdesk-flutter
          termius
        ]
      )
      ++ lib.optionals cfg.teams.enable [ pkgs.teams-for-linux ];

    home.file.".vscode/argv.json".text = builtins.toJSON {
      password-store = "gnome-libsecret";
      enable-crash-reporter = false;
    };
  };
}
