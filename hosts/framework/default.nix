# Framework 13 AMD client.
{
  pkgs,
  me,
  r,
  ...
}:

{
  imports = with r; [
    (profilesNixos + /client.nix)
    ./hardware-configuration.nix
    ./hardware.nix
    (modulesNixos + /desktop/sway.nix)
    (modulesNixos + /services/printing.nix)
  ];

  nighthawk.kernel = "latest";

  boot = {
    loader = {
      systemd-boot.enable = true;
      systemd-boot.configurationLimit = 20;
      efi.canTouchEfiVariables = true;
    };
    kernelParams = [ "amd_pstate=active" ];
  };

  hardware = {
    enableRedistributableFirmware = true;
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        vulkan-loader
        vulkan-tools
        vulkan-validation-layers
      ];
      extraPackages32 = with pkgs.pkgsi686Linux; [ vulkan-loader ];
    };
  };

  services = {
    fprintd.enable = true;
    fwupd.enable = true;
    power-profiles-daemon.enable = true;
  };

  networking = {
    hostName = "framework";
    networkmanager.enable = true;
  };
  systemd.services.NetworkManager-wait-online.enable = false;

  programs = {
    tmux.enable = true;
    zsh.shellInit = ''
      LOCALCOLOR=$'%{\e[1;32m%}'
    '';
  };

  users.users.${me}.extraGroups = [
    "networkmanager"
    "video"
  ];

  home-manager.users.${me}.imports = [ ./home.nix ];

  system.stateVersion = "24.05";
}
