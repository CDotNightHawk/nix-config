# niri Wayland compositor.
#
# Uses the upstream niri-flake (sodiboo/niri-flake) — pulling the
# NixOS module gives us:
#   - `pkgs.niri-stable` / `pkgs.niri-unstable` overlays
#   - `services.displayManager.sessionPackages` automatically wired
#     so display managers (ly, gdm, sddm) list a "niri" session
#   - desktop portals + polkit
#
# DMS (Dank Material Shell) recommends running niri 25.11 from
# nixpkgs rather than niri-stable 25.08 from niri-flake; we follow
# that recommendation by setting `package = pkgs.niri`.
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.niri.nixosModules.niri
  ];

  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };

  # Reasonable defaults for a niri box, all of which the niri-flake
  # module would not set on its own.
  security.polkit.enable = true;

  # XDG portals: niri-flake enables xdg-desktop-portal-gnome by
  # default. We add the gtk portal so non-GTK apps (Firefox, Electron)
  # still get filechooser/screenshare working under niri.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # niri-flake's portal pulls in gnome-keyring's gcr-ssh-agent.
  # We already manage ssh-agent ourselves via modules/nixos/ssh.nix, so disable
  # gcr-ssh-agent here to avoid the upstream "two ssh-agents" assert.
  services.gnome.gcr-ssh-agent.enable = lib.mkForce false;

  # Wayland-friendly defaults
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # Chromium/Electron native Wayland
    MOZ_ENABLE_WAYLAND = "1";
  };

  environment.systemPackages = with pkgs; [
    # The basic niri ecosystem most users expect to find on PATH
    swaylock
    swayidle
    waybar
    wl-clipboard
    cliphist
    grim
    slurp
    wf-recorder
    brightnessctl
    playerctl
    pamixer
    libnotify
    mako # notification daemon (fallback if DMS isn't running)
    fuzzel # launcher (fallback)

    # XWayland bridge for niri. niri is pure Wayland and ships no
    # built-in XWayland server (unlike sway/hyprland), so X11 apps
    # — Steam, JetBrains IDEs, Zoom, a long tail of Electron apps
    # that still haven't flipped on Wayland — fail with "Unable to
    # open a connection to X" unless an external XWayland proxy is
    # running. xwayland-satellite launches XWayland on-demand when
    # an X client tries to connect to DISPLAY.
    #
    # Spawning + DISPLAY wiring happens in the home-manager niri
    # config (modules/home/desktop/niri-dms.nix) so it only runs
    # inside a niri session.
    xwayland-satellite
  ];
}
