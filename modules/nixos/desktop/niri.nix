{
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [ inputs.niri.nixosModules.niri ];

  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };

  security.polkit.enable = true;
  services.gnome.gcr-ssh-agent.enable = lib.mkForce false;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  environment = {
    sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
      NIXOS_OZONE_WL = "1";
    };
    systemPackages = with pkgs; [
      brightnessctl
      cliphist
      fuzzel
      grim
      libnotify
      mako
      pamixer
      playerctl
      slurp
      swayidle
      swaylock
      waybar
      wf-recorder
      wl-clipboard
      xwayland-satellite
    ];
  };
}
