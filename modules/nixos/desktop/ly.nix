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

  # Don't run a graphical greeter on tty1; ly defaults to tty2.
  # If you need ctrl-alt-F2 for ly and ctrl-alt-F1 for a console,
  # this is already correct.
}
