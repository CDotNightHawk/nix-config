# /etc/hosts/nixos/configuration.nix
{ config, pkgs, inputs, ... }:

{
  imports = [
    # Import machine-specific hardware settings
    ./hardware-configuration.nix

    # Import shared system settings
    ../modules/nixos/common.nix
  ];

  # Bootloader settings
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "framework"; # MUST match the name in flake.nix

  environment.variables.EDITOR = "${pkgs.neovim}/bin/nvim";
  
  programs.zsh.shellAliases = {
    # Define your alias here. I'll call it 'nrs' for 'Nixos Rebuild Switch'.
    nrs = "sudo nixos-rebuild switch --flake .#framework";
    # You could also add one for the documentation:
    nrd = "sudo nixos-rebuild dry-run --flake .#framework";
  };

  users.users.nighthawk = {
    isNormalUser = true;
    description = "nighthawk";
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
      "libvirtd"
      "disk"
      "dialout"
      "tty"
    ];
    packages = with pkgs; [ git ];
    #openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII8HkvcXKlOxWg296i3iANJN5+y0o3RJCBD4/QBKX/kf" ];
  };
  
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # This is crucial for Steam
  };
  hardware.graphics.extraPackages = with pkgs; [
    vulkan-loader
    vulkan-tools
    vulkan-validation-layers
  ];
  hardware.graphics.extraPackages32 = with pkgs.pkgsi686Linux; [
    vulkan-loader
  ];

  # Enable fingerprint support (hardware-specific)
  services.fprintd.enable = true;

  
  # Set the state version for this specific machine
  system.stateVersion = "25.05";
}
