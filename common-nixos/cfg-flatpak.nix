{ config, lib, pkgs, ... }:

{
  # Enable the system-wide Flatpak service
  services.flatpak.enable = true;

  # Enable XDG portals
  # This is crucial for Flatpak apps to integrate properly
  # with the desktop environment (e.g., file pickers, themes, fonts).
  xdg.portal = {
    enable = true;
    # NixOS will try to auto-detect your desktop environment,
    # but you can explicitly add backends if needed.
    # Just uncomment the one for your DE:
    # extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    # extraPortals = [ pkgs.xdg-desktop-portal-kde ];
    # extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
  };
}