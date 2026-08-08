# Secret Service integration for desktop credential storage.
{ pkgs, ... }:

{
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.ly.enableGnomeKeyring = true;

  environment.systemPackages = with pkgs; [
    libsecret
    seahorse
  ];
}
