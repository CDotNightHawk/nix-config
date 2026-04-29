# Sway: a vanilla Wayland fallback session.
#
# Niri is the daily driver; Sway is here so that ly always has at
# least one alternative Wayland session to pick. Useful when:
#   - niri segfaults on a kernel/driver regression and you need to
#     log in to fix the config from a working compositor
#   - you want to demo a more "traditional" tiling WM to someone
#   - DMS' QuickShell is misbehaving and you want to rule out niri
#     vs. DMS as the culprit
#
# Sway pulls in its own polkit + xdg-desktop-portal-wlr; we only need
# the system-side knob that registers `sway.desktop` in
# `share/wayland-sessions/`. Per-user keybinds / config live in
# `~/.config/sway/config` (we don't ship one — Sway's default
# bindings work fine for an emergency session).
{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      foot # default terminal
      fuzzel # launcher (matches niri side)
      grim
      slurp
      wl-clipboard
      mako
    ];
  };
}
