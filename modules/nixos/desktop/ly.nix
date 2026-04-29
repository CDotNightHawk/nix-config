# ly: a TUI display manager. Tiny, fast, fits niri's vibe.
#
# Important: ly only lists a session if some module has populated
# `services.displayManager.sessionPackages` (or installed a
# `*.desktop` file under `/run/current-system/sw/share/wayland-sessions/`).
# Importing `desktop/niri.nix` (which uses `inputs.niri.nixosModules.niri`)
# does that automatically. If you also want a GNOME / KDE fallback,
# enable those modules and they'll show up too.
{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.displayManager.ly = {
    enable = true;
    settings = {
      # Move ly off tty1 (nixpkgs default) onto tty7, the long-standing
      # convention for graphical sessions. Two reasons:
      #   - tty1 stays available for an actual console login, which is
      #     critical when you're debugging a half-broken rebuild and
      #     can't start a Wayland session.
      #   - `nixos-rebuild switch` reloads dbus.service. If ly is on the
      #     active VT, that reload kills the greeter and any in-progress
      #     login. Parking ly on tty7 means the rebuild's dbus reload
      #     doesn't take down whatever console you're currently on.
      tty = lib.mkForce 7;

      animate = true;
      animation = "matrix";
      hide_borders = true;
      clock = "%c";
      bigclock = "en";
      input_len = 34;
      blank_box = true;
      asterisk = "*";
      # Default to the most-recently-used session.
      load = true;
      save = true;
    };
  };

  # Make sure agetty keeps tty1 free for a console login. NixOS does
  # this by default, but if some other module (e.g. an old SDDM leftover)
  # tries to grab tty1 for the greeter, this assert flushes it out.
}
