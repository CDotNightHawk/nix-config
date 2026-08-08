{
  lib,
  inputs,
  r,
  ...
}:

{
  imports = with r; [
    (libs + /nix-settings.nix)
    (modulesNixos + /auto-optimise.nix)
    (modulesNixos + /auto-upgrade.nix)
    (modulesNixos + /gc.nix)
    (modulesNixos + /kernel.nix)
    (modulesNixos + /locale.nix)
    (modulesNixos + /nix.nix)
    (modulesNixos + /security.nix)
    (modulesNixos + /shell-aliases.nix)
    (modulesNixos + /sundry.nix)
    (modulesNixos + /system-packages.nix)
    (modulesNixos + /users.nix)
    (modulesNixos + /xdg.nix)
    (modulesNixos + /zsh.nix)
    inputs.lix-module.nixosModules.default
  ];

  boot.tmp.cleanOnBoot = true;

  networking.firewall = {
    enable = true;
    allowPing = true;
    checkReversePath = "loose";
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
    randomizedDelaySec = "45min";
  };

  services = {
    fstrim.enable = lib.mkDefault true;
    journald.extraConfig = ''
      SystemMaxUse=512M
      MaxRetentionSec=1month
    '';
  };

  zramSwap = {
    enable = lib.mkDefault true;
    memoryPercent = lib.mkDefault 25;
    priority = lib.mkDefault 100;
  };
}
