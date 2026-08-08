# Intel Rocket Lake and AMD RDNA4 workstation client.
{
  pkgs,
  me,
  r,
  inputs,
  ...
}:

{
  imports = with r; [
    (profilesNixos + /client.nix)
    inputs.disko.nixosModules.disko
    ./disko.nix
    ./hardware.nix
    (modulesNixos + /services/avahi.nix)
    (modulesNixos + /services/syncthing.nix)
    (modulesNixos + /ssh.nix)
    (modulesNixos + /virt/libvirt.nix)
  ];

  nighthawk = {
    kernel = "latest";
    ssh = {
      enable = true;
      allowTcpForwarding = true;
    };
  };

  boot.loader = {
    systemd-boot.enable = true;
    systemd-boot.configurationLimit = 20;
    efi.canTouchEfiVariables = true;
  };

  hardware = {
    enableRedistributableFirmware = true;
    enableAllFirmware = true;
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        libva-utils
        mesa
        vulkan-extension-layer
        vulkan-loader
        vulkan-tools
        vulkan-validation-layers
      ];
      extraPackages32 = with pkgs.pkgsi686Linux; [ vulkan-loader ];
    };
  };

  environment.systemPackages = with pkgs; [
    amdgpu_top
    android-tools
    lact
    nvtopPackages.amd
    radeontop
  ];

  networking = {
    hostName = "workstation";
    networkmanager.enable = true;
  };
  systemd.services.NetworkManager-wait-online.enable = false;

  users.users.${me}.extraGroups = [
    "audio"
    "networkmanager"
    "plugdev"
    "render"
    "video"
  ];

  home-manager.users.${me}.imports = [ ./home.nix ];

  system.stateVersion = "24.05";
}
