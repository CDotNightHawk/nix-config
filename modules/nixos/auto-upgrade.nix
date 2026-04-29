# Weekly automated `nix flake update + nixos-rebuild boot`.
#
# Why `boot` and not `switch`:
#   - `switch` activates the new generation immediately. That can
#     reload dbus, kill long-running user processes, and generally
#     surprise you mid-session. We don't want surprise updates.
#   - `boot` builds the new generation, registers it as the default
#     entry in systemd-boot, and otherwise leaves the running system
#     alone. You pick up the update on your next reboot, on your
#     terms — and if the new generation breaks, you can pick the
#     previous one from the boot menu.
#
# Logs go to `journalctl -u nixos-upgrade.service`.
# To rebuild on demand instead of waiting for the timer:
#   doas nixos-rebuild boot --flake /etc/nixos#framework
# (or use the niri keybind Mod+Shift+U from desktop/niri-dms.nix.)
{
  config,
  lib,
  pkgs,
  ...
}:
 
{
  system.autoUpgrade = {
    enable = true;
 
    # Point at the user's working clone. `system.autoUpgrade` runs as
    # root, but root can read /home/nighthawk just fine. Using the
    # same checkout the user edits means a manual `git pull` and an
    # auto-upgrade always agree on what code is current.
    #
    # NOTE: this path must exist on the system — the bootstrap is
    # `git clone https://github.com/CDotNightHawk/nix-config ~/nix-config`.
    # If you ever move/rename the clone, update this string too.
    flake = "/home/nighthawk/nix-config#${config.networking.hostName}"; 
    # `boot` instead of the default `switch`. See header.
    operation = "boot";
 
    # Update flake inputs (nixpkgs, niri, dms, lix, etc.) before
    # building, so the weekly job actually picks up new versions.
    # We deliberately do NOT pass `--commit-lock-file`: the systemd
    # job runs as root and root has no git identity configured;
    # leaving flake.lock dirty lets you review the diff and commit
    # when you're ready (`cd ~/nix-config && git diff flake.lock`).    
    flags = [
      "--update-input"
      "nixos-unstable"
      "--update-input"
      "home-manager"
      "--update-input"
      "niri"
      "--update-input"
      "dms"
      "--update-input"
      "lix"
      "--update-input"
      "lix-module"
    ];
 
    # Sundays at 04:00 local time. systemd will run the job on
    # next boot if the laptop was suspended/off at the scheduled
    # time (Persistent=true is set by the NixOS module by default).
    dates = "Sun *-*-* 04:00:00";
 
    # Random ±30min jitter so a fleet of machines doesn't hammer
    # cache.nixos.org / cachix at the same instant.
    randomizedDelaySec = "30min";
 
    # Don't reboot automatically. We want the user to reboot when
    # they're ready (and to *see* the closure diff — see sundry.nix
    # — so they know whether the new generation touched dbus).
    allowReboot = false;
  };
 
  # Keep ~6 weeks of generations available in the bootloader so a bad
  # auto-upgrade is always one reboot away from being undone.
  # `boot.loader.systemd-boot.configurationLimit` is set per-host;
  # don't override it here.
}
