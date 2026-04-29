# PolicyKit rules: silently allow `nighthawk` (anyone in the wheel
# group, really) to drive the GUI admin tools — printers, NetworkManager,
# fwupd, mounting external disks, suspend/reboot — without typing a
# password every time.
#
# This is the GUI counterpart to the doas rules in security.nix.
# Together they cover both CLI (`doas nixos-rebuild ...`) and GUI
# (clicking "Add Printer", "Connect to WiFi", "Update firmware") flows.
#
# polkit JS API reference:
#   https://www.freedesktop.org/software/polkit/docs/latest/polkit.8.html
#
# To list all available actions on the running system:
#   pkaction --verbose
{
  config,
  lib,
  pkgs,
  ...
}:
 
{
  # `nighthawk` is in the wheel group (set in modules/nixos/users.nix).
  # The default polkit policy in NixOS already prompts wheel users for
  # *their own* password instead of root's; we relax that to no-prompt
  # for the specific action namespaces below.
  security.polkit.enable = true;
 
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (!subject.isInGroup("wheel")) {
        return polkit.Result.NOT_HANDLED;
      }
 
      var passwordlessActions = [
        // CUPS — add/remove/configure printers, manage jobs
        "org.opensuse.cupspkhelper.mechanism.",
 
        // NetworkManager — enable/disable wifi, switch connections,
        // edit system connections (so the DMS network applet just works)
        "org.freedesktop.NetworkManager.",
 
        // fwupd — apply firmware updates without typing a password
        // mid-update (this matters: fwupd updates are interactive and
        // a password prompt during a UEFI capsule write is dangerous)
        "org.freedesktop.fwupd.",
 
        // udisks2 — mount external USB drives, NTFS partitions, etc.
        "org.freedesktop.udisks2.",
 
        // GNOME control center / DMS settings panel power actions —
        // suspend, reboot, poweroff. Already-default for active session
        // but explicit is fine.
        "org.freedesktop.login1.suspend",
        "org.freedesktop.login1.reboot",
        "org.freedesktop.login1.power-off",
        "org.freedesktop.login1.hibernate",
 
        // Bluetooth pairing / connection management
        "org.blueman.",
        "org.bluez."
      ];
 
      for (var i = 0; i < passwordlessActions.length; i++) {
        var prefix = passwordlessActions[i];
        // endsWith "." → namespace match; else exact match
        if (prefix.charAt(prefix.length - 1) === ".") {
          if (action.id.indexOf(prefix) === 0) {
            return polkit.Result.YES;
          }
        } else if (action.id === prefix) {
          return polkit.Result.YES;
        }
      }
 
      return polkit.Result.NOT_HANDLED;
    });
  '';
}
