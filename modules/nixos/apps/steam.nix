# Steam + the gaming-on-Linux stack.
#
# Wires up:
#   - programs.steam (with Steam Remote Play + dedicated-server firewall
#     openings, plus a `gamescopeSession` ly entry so you can drop
#     straight into Steam Big Picture / Gamescope from the login
#     manager — useful for couch-mode on the workstation).
#   - programs.gamemode (Feral's CPU-governor / niceness / I/O tweaks
#     that get applied while a game is running).
#   - programs.gamescope SUID wrapper so per-game gamescope launchers
#     can grab the realtime scheduler.
#   - Proton-GE-Custom as an `extraCompatPackages` entry so it shows up
#     in Steam → Properties → Compatibility alongside stock Proton.
#   - 32-bit OpenGL/Vulkan via `hardware.graphics.enable32Bit = true`
#     (set per-host, since the extraPackages list is GPU-specific).
#
# Network openings are scoped to the Steam-specific ports
# (UDP 27031-27036 + TCP 27036-27037 for Remote Play, plus the
# dedicated-server ranges) — programs.steam handles that for us when
# remotePlay.openFirewall / dedicatedServer.openFirewall are true.
{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.steam = {
    enable = true;

    # Open the firewall holes Steam Remote Play / In-Home Streaming
    # need (UDP 27031-27036, TCP 27036-27037).
    remotePlay.openFirewall = true;

    # Source-engine dedicated-server ports + Steam game ports
    # (TCP/UDP 27015 family). Safe to leave on; nothing listens
    # unless you're actually hosting.
    dedicatedServer.openFirewall = true;

    # Adds a "Gamescope (Steam)" wayland-session .desktop file under
    # /run/current-system/sw/share/wayland-sessions/, which means ly
    # gets a third entry next to "Niri" and "Sway". Pick that to land
    # in Steam Big Picture full-screen with gamescope underneath —
    # great for SteamOS-on-the-couch behavior.
    gamescopeSession.enable = true;

    # Make Proton-GE-Custom selectable from
    # Steam → Properties → Compatibility → Run with...
    # without manually dropping it into ~/.steam/.../compatibilitytools.d.
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };

  # Feral's gamemoded — Steam launches games with `gamemoderun %command%`
  # by default once this is on. Renices the game, pins the CPU governor
  # to performance, disables turbo throttling, etc.
  programs.gamemode = {
    enable = true;
    enableRenice = true;
  };

  # gamescope as a setuid-root wrapper so per-game launchers can pick
  # up the realtime scheduling capability without the user being in a
  # special group. Required for low-latency frame pacing inside the
  # Gamescope session.
  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  # Tools the gaming stack expects on PATH (mangohud overlay, the
  # vkBasalt post-processing layer, and protontricks for fixing
  # broken-game prefixes).
  environment.systemPackages = with pkgs; [
    mangohud
    vkbasalt
    protontricks
    winetricks
    wineWowPackages.staging
  ];

  # 32-bit graphics drivers must be enabled at the host level (the
  # extraPackages32 list depends on the GPU). Both framework and
  # workstation already set hardware.graphics.enable32Bit = true.
  # Sanity-assert here so a future host that imports this module
  # without enabling 32-bit graphics fails fast at eval.
  assertions = [
    {
      assertion = config.hardware.graphics.enable32Bit;
      message = ''
        modules/nixos/apps/steam.nix requires
        hardware.graphics.enable32Bit = true; for the 32-bit Vulkan/GL
        loader Steam needs. Enable it in your host's default.nix.
      '';
    }
  ];
}
