# Chat and messaging clients.
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    vesktop
    signal-desktop
    telegram-desktop
  ];
}
