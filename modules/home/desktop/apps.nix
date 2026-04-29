# Desktop applications that don't belong in a more specific module.
#
# Everything here is native Nix where possible — we use flatpak as
# a fallback only for apps that aren't in nixpkgs or that only
# ship upstream as a flatpak.
#
# See modules/nixos/apps/flatpak.nix for the flatpak reconciler that
# handles the few apps listed as flatpak-only here.
{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    # Portal for Teams — unofficial Electron Teams client. Works fine
    # under Wayland via NIXOS_OZONE_WL (set in niri.nix).
    teams-for-linux

    # Easy Effects — PipeWire audio-effects GUI (noise suppression,
    # EQ, loudness). Pipes every sink through ladspa/lv2 plugins.
    easyeffects

    # RustDesk — open-source TeamViewer alternative. Use the Flutter
    # build; the legacy Sciter UI (`rustdesk`) is deprecated
    # upstream and flagged as such in nixpkgs.
    rustdesk-flutter

    # Transmission — BitTorrent client (GTK front-end). `_4-gtk`
    # pins to the Transmission 4.x series which has WebRTC + IPv6
    # fixes over the 3.x line still in nixos-stable.
    transmission_4-gtk

    # Nicotine+ — SoulSeek peer-to-peer client.
    nicotine-plus

    # Prism Launcher — Minecraft launcher (MultiMC fork). Handles
    # mod loaders, Java version juggling, per-instance Java opts.
    prismlauncher

    # Bottles — Wine prefix manager. Native nix build works; if
    # you hit 32-bit wine dependency issues, switch this entry to
    # the flatpak version (com.usebottles.bottles) in
    # modules/nixos/apps/flatpak.nix.
    bottles
  ];
}
