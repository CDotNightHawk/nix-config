# CUPS printing.
#
# Wires up the userspace printing stack:
#   - cups daemon (services.printing) discovers and drives printers
#   - cups-pk-helper provides the polkit rules so unprivileged GUI apps
#     (the DMS settings panel, GNOME's printer applet, the GTK print
#     dialog) can add/configure printers without sudo
#   - avahi (mDNS/DNS-SD) lets cups auto-discover networked printers
#   - gutenprint adds open-source drivers for ~700 printer models
#
# If you only ever print to a specific printer add its driver to
# `services.printing.drivers` (e.g. pkgs.hplip for HP, pkgs.brlaser
# for Brother lasers) so the driver is realised at switch time.
{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.printing = {
    enable = true;

    # Common driver bundles. Pull in extras per-host as needed.
    drivers = with pkgs; [
      gutenprint
      gutenprintBin
    ];
  };

  # PolicyKit bridge for cups: lets the DMS / GTK printer dialog add
  # and configure printers without prompting for the root password.
  services.system-config-printer.enable = true;
  programs.system-config-printer.enable = true;
  environment.systemPackages = [ pkgs.cups-pk-helper ];

  # Auto-discover network printers (IPP/AirPrint).
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
