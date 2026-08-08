# Recovery Wayland session for the Framework client.
{ pkgs, ... }:

{
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraPackages = with pkgs; [
      foot
      fuzzel
      grim
      mako
      slurp
      wl-clipboard
    ];
  };
}
