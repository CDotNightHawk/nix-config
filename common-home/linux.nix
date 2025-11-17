# Inspired by https://codeberg.org/ihaveahax/nix-config
{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.ssh-agent.enable = true;

  programs.zsh = {
    shellAliases = {
      pbcopy = "if [ -n \"$WAYLAND_DISPLAY\" ]; then wl-copy; else xclip -selection clipboard; fi";
      pbpaste = "if [ -n \"$WAYLAND_DISPLAY\" ]; then wl-paste; else xclip -selection clipboard -o; fi";

      open = "xdg-open";
    };
  };

  home.packages = with pkgs; [
    # X11 Clipboard support (Legacy/Headless)
    xclip
    # Wayland Clipboard support (Modern/Plasma 6)
    wl-clipboard

    # System monitoring tools useful specifically on Linux
    sysstat       # iostat, mpstat, pidstat
    lm_sensors    # check cpu temperatures
  ];
  systemd.user.startServices = "sd-switch";
}
