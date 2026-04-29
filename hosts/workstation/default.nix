# Workstation host: Intel i9 (11th gen Rocket Lake) + AMD RX 9070 XT.
#
# Reuses the same modules as the framework host; differences are
# confined to this file + ./hardware.nix + ./disko.nix.
#
# Before first install: edit ./disko.nix and replace the
# `/dev/disk/by-id/REPLACE-ME` placeholder with the real disk ID, and
# replace ./hardware.nix with the output of
# `nixos-generate-config --no-filesystems --root /mnt`.
{
  config,
  lib,
  pkgs,
  me,
  r,
  inputs,
  ...
}:

{
  imports = with r; [
    inputs.disko.nixosModules.disko
    ./disko.nix
    ./hardware.nix

    # Shared nix daemon settings (caches, registries, lix, allowUnfree).
    (libs + /nix-settings.nix)

    # System
    (modulesNixos + /sundry.nix)
    (modulesNixos + /home-manager.nix)
    (modulesNixos + /system-packages.nix)
    (modulesNixos + /kernel.nix)
    (modulesNixos + /nix.nix)
    (modulesNixos + /users.nix)
    (modulesNixos + /auto-optimise.nix)
    (modulesNixos + /auto-upgrade.nix)
    (modulesNixos + /polkit-rules.nix)
    (modulesNixos + /xdg.nix)
    (modulesNixos + /zsh.nix)
    (modulesNixos + /shell-aliases.nix)
    (modulesNixos + /gc.nix)
    (modulesNixos + /locale.nix)

    # Niri + DMS + ly stack
    (modulesNixos + /desktop/niri.nix)
    (modulesNixos + /desktop/dms.nix)
    (modulesNixos + /desktop/ly.nix)
    (modulesNixos + /desktop/sound.nix)
    (modulesNixos + /desktop/firefox.nix)

    # Steam + gamescope + gamemode + Proton-GE.
    (modulesNixos + /apps/steam.nix)

    # Flatpak + Flathub (declarative via nix-flatpak module).
    inputs.nix-flatpak.nixosModules.nix-flatpak
    (modulesNixos + /apps/flatpak.nix)

    # Security: doas only.
    (modulesNixos + /security.nix)

    # Containers / virt — workstation runs VMs and dev containers
    (modulesNixos + /virt/podman.nix)
    (modulesNixos + /virt/docker.nix)
    (modulesNixos + /virt/libvirt.nix)

    # Networking-adjacent services
    (modulesNixos + /services/avahi.nix)
    (modulesNixos + /services/syncthing.nix)
    (modulesNixos + /ssh.nix)

    # Third-party
    inputs.night-nur.nixosModules.overlay
    inputs.lix-module.nixosModules.default
    inputs.sops-nix.nixosModules.sops
  ];

  # --- Boot ---------------------------------------------------------------
  boot = {
    loader = {
      systemd-boot.enable = true;
      systemd-boot.configurationLimit = 20;
      efi.canTouchEfiVariables = true;
    };
    tmp.cleanOnBoot = true;
  };

  # 11th-gen Intel does NOT need amd_pstate (obviously) and benefits
  # from intel_pstate active mode by default. Microcode handled in
  # hardware.nix.

  # AMD RX 9070 XT (RDNA4) — RDNA4 needs Mesa 24.3+ / kernel 6.13+ for
  # full support, so make sure modules/nixos/kernel.nix sets `latest`.
  nighthawk.kernel = "latest";

  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      vulkan-loader
      vulkan-tools
      vulkan-validation-layers
      vulkan-extension-layer
      libva-utils
      mesa
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      vulkan-loader
    ];
  };

  # AMD GPU monitoring + Android tools (programs.adb is gone in newer
  # nixpkgs; just install android-tools).
  environment.systemPackages = with pkgs; [
    amdgpu_top
    radeontop
    nvtopPackages.amd
    lact # GUI overclocking / fan control for AMD GPUs
    android-tools
  ];

  services.fstrim.enable = true;

  # --- Networking ---------------------------------------------------------
  networking = {
    hostName = "workstation";
    networkmanager.enable = true;
  };

  systemd.services.NetworkManager-wait-online.enable = false;

  # --- Nix GC -------------------------------------------------------------
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # --- Programs -----------------------------------------------------------
  # Steam, gamescope, gamemode, Proton-GE all live in
  # ../../modules/nixos/apps/steam.nix (imported above) so the framework
  # gets the same gaming stack.

  zramSwap.enable = true;

  users.users.${me}.extraGroups = [
    "networkmanager"
    "video"
    "render"
    "audio"
    "plugdev"
  ];

  # --- Home Manager -------------------------------------------------------
  home-manager.users.${me}.imports = [ ./home.nix ];

  system.stateVersion = "24.05";
}
