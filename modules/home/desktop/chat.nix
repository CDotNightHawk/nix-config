# Chat / messaging clients.
#
# Vesktop is a custom Discord client (Electron + Vencord) — runs better
# on Wayland than the official Discord build (proper screen sharing,
# native window controls, no Xwayland fallback).
#
# Telegram Desktop is the upstream Qt client; works on Wayland out of
# the box and integrates with notification daemons.
{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    vesktop
    telegram-desktop
  ];
}
