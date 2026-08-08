# Declarative system-wide Flathub applications.
{
  lib,
  pkgs,
  ...
}:

{
  services.flatpak = {
    enable = true;
    remotes = [
      {
        name = "flathub";
        location = "https://flathub.org/repo/flathub.flatpakrepo";
      }
    ];
    packages = [
      {
        # Soundux is no longer packaged by nixpkgs.
        appId = "io.github.Soundux";
        origin = "flathub";
      }
      {
        appId = "com.usebottles.bottles";
        origin = "flathub";
      }
    ];
    uninstallUnused = false;
    update = {
      auto = {
        enable = true;
        onCalendar = "weekly";
      };
      onActivation = false;
    };
  };

  xdg.portal = {
    enable = true;
    wlr.enable = lib.mkDefault true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
}
