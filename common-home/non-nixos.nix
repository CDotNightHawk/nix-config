# Inspired by https://codeberg.org/ihaveahax/nix-config
{
  config,
  lib,
  pkgs,
  ...
}:

{
  nix = {
    package = lib.mkDefault pkgs.nix;
    
    settings = {
      netrc-file = lib.mkForce "${config.home.homeDirectory}/.config/nix/netrc";
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
    };

    # Clean up old generations automatically
    gc = {
      automatic = true;
      frequency = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  systemd.user = {
    # Explicitly set the path if your distro puts it elsewhere
    systemctlPath = "/usr/bin/systemctl";
    startServices = "sd-switch";
  };

  # Help the host OS find fonts installed by Home Manager
  fonts.fontconfig.enable = true;

  # Attempt to register Nix desktop files with the host OS
  xdg.mime.enable = true;
  xdg.systemDirs.data = [ "${config.home.homeDirectory}/.nix-profile/share" ];

  programs.home-manager.enable = true;

  # Enable generic Linux integration only if on Linux
  targets.genericLinux.enable = lib.strings.hasSuffix "linux" config.nixpkgs.system;
}