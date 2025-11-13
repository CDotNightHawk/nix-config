# custom-folder-icons.nix

{ config, pkgs, lib, ... }:

let
  cfg = config.customFolderIcons;

  # Helper function to generate the icon path in the nix store
  iconPackage = pkgs.stdenv.mkDerivation {
    name = "custom-folder-icons";
    src = cfg.iconDir;
    installPhase = ''
      mkdir -p $out
      cp -r ./* $out/
    '';
  };

in
{
  options.customFolderIcons = {
    enable = lib.mkEnableOption "Enable custom folder icons";

    desktopEnvironment = lib.mkOption {
      type = lib.types.enum [ "gnome" "kde" ];
      default = "gnome";
      description = "The desktop environment to apply folder icons for.";
    };

    iconDir = lib.mkOption {
      type = lib.types.path;
      description = "The directory containing your custom icon files.";
      example = "/path/to/your/icons";
    };

    folderMap = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "An attribute set mapping folder paths to icon file names.";
      example = {
        "~/Documents" = "documents.svg";
        "~/Projects/Nix" = "nix.png";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Ensure necessary tools are available
    home.packages = with pkgs; [
      (lib.mkIf (cfg.desktopEnvironment == "gnome") glib) # for gio
    ];

    # Implementation for KDE Plasma
    home.file = lib.mkIf (cfg.desktopEnvironment == "kde") (
      lib.mapAttrs' (folderPath: iconName: {
        name = "${folderPath}/.directory";
        value = {
          text = ''
            [Desktop Entry]
            Icon=${iconPackage}/${iconName}
          '';
        };
      }) cfg.folderMap
    );

    # Implementation for GNOME (and other GTK-based DEs)
    home.activation = lib.mkIf (cfg.desktopEnvironment == "gnome") {
      setFolderIcons = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        echo "Setting custom folder icons..."
        ${lib.concatStringsSep "\n" (
          lib.mapAttrsToList (folderPath: iconName:
            let
              # Resolve ~ to the home directory for the activation script
              resolvedPath = lib.replaceStrings [ "~" ] [ config.home.homeDirectory ] folderPath;
            in
            ''
              ${pkgs.glib}/bin/gio set -t string "${resolvedPath}" metadata::custom-icon "file://${iconPackage}/${iconName}"
            ''
          ) cfg.folderMap
        )}
        echo "Custom folder icons set."
      '';
    };
  };
}