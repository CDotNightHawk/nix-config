# Workstation host: Intel i9 (11th gen Rocket Lake) + AMD RX 9070 XT.
#
# Reuses the same common-nixos / common-home modules as the framework
# host; differences are confined to this file + ./hardware-stub.nix
# (replace with a real generated hardware-configuration.nix at install
# time) + ./disko-config.nix.
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
    ./disko-config.nix
    ./hardware-stub.nix

    # Shared nix settings + caches.
    (extras + /shared-nix-settings.nix)

    # Core system modules
    (common-nixos + /cfg-misc.nix)
    (common-nixos + /cfg-home-manager.nix)
    (common-nixos + /cfg-common-system-packages.nix)
    (common-nixos + /cfg-linux-kernel.nix)
    (common-nixos + /cfg-nix-settings.nix)
    (common-nixos + /cfg-my-user.nix)
    (common-nixos + /cfg-auto-optimise.nix)
    (common-nixos + /cfg-xdg.nix)
    (common-nixos + /cfg-zsh.nix)
    (common-nixos + /cfg-shell-aliases.nix)
    (common-nixos + /cfg-delete-old-hm-profiles.nix)
    (common-nixos + /cfg-time-and-i18n.nix)

    # Niri + DMS + ly stack
    (common-nixos + /cfg-niri.nix)
    (common-nixos + /cfg-dms.nix)
    (common-nixos + /cfg-display-manager-ly.nix)
    (common-nixos + /cfg-sound.nix)
    (common-nixos + /cfg-firefox.nix)

    # doas-only
    (common-nixos + /cfg-security.nix)

    # Containers / virt — workstation runs VMs and dev containers
    (common-nixos + /cfg-podman.nix)
    (common-nixos + /cfg-docker.nix)
    (common-nixos + /cfg-libvirt.nix)

    # Networking-adjacent
    (common-nixos + /cfg-avahi.nix)
    (common-nixos + /cfg-syncthing.nix)
    (common-nixos + /cfg-ssh.nix)

    # Third-party modules
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
  # hardware-stub.nix.

  # AMD RX 9070 XT (RDNA4) — RDNA4 needs Mesa 24.3+ / kernel 6.13+ for
  # full support, so make sure cfg-linux-kernel sets `latest` here.
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

  # AMD GPU monitoring + Android tools (programs.adb is gone in
  # newer nixpkgs; just install android-tools).
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
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };

  programs.gamemode.enable = true;

  # Zram on a 32-64GB box doesn't hurt, and it's useful when running
  # multiple VMs.
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
