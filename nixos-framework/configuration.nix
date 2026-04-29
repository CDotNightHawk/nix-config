# Framework 13 AMD (Ryzen 7040 / AI 300 series) + Intel AX210 WiFi
#
# This is the root module for the `framework` nixosConfiguration.
# Anything genuinely laptop- or host-specific lives here; everything
# reusable lives in ../common-nixos/*.
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
    # Hardware / generated
    ./hardware-configuration.nix
    ./framework-hardware.nix

    # Shared nix settings (caches, registries, lix, allowUnfree).
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

    # Desktop / laptop essentials
    (common-nixos + /cfg-plasma6.nix)
    (common-nixos + /cfg-sound.nix)
    (common-nixos + /cfg-firefox.nix)

    # Security: doas only. See cfg-security.nix. Do NOT also import
    # cfg-sudo-config.nix here -- sudo is disabled.
    (common-nixos + /cfg-security.nix)

    # Containers / virt
    (common-nixos + /cfg-podman.nix)

    # SSH (system side). Note: this allows root+me login via your
    # extras/id_rsa.pub and enables fail2ban. If you don't want sshd
    # on your laptop, drop this import.
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

    # AMD P-state driver gives much better perf/power scaling on
    # Framework 13 AMD than the legacy acpi-cpufreq.
    kernelParams = [
      "amd_pstate=active"
    ];

    tmp.cleanOnBoot = true;

    # Framework 13 AMD ships with a MediaTek MT7925 by default, but
    # NightHawk has swapped in an Intel card (AX210/BE200). No custom
    # modprobe options are needed for the stock iwlwifi defaults; if
    # you ever see AX210 disconnects, uncomment the block below.
    # extraModprobeConfig = ''
    #   options iwlwifi power_save=0 11n_disable=8
    #   options iwlmvm power_scheme=1
    # '';
  };

  # Enable all redistributable firmware (iwlwifi, amdgpu, etc.).
  hardware.enableRedistributableFirmware = true;

  # AMD iGPU (+ Steam / 32-bit OpenGL).
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    # RADV is enabled by default for AMD; just add the userspace tools.
    extraPackages = with pkgs; [
      vulkan-loader
      vulkan-tools
      vulkan-validation-layers
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      vulkan-loader
    ];
  };

  # Framework firmware updates flow through LVFS / fwupd.
  services.fwupd.enable = true;

  # Let KDE Power Management switch profiles (balanced/performance/saver).
  # Must NOT be combined with TLP.
  services.power-profiles-daemon.enable = true;

  # Fingerprint reader.
  services.fprintd.enable = true;

  # --- Networking ---------------------------------------------------------
  networking = {
    hostName = "framework";
    networkmanager.enable = true;
  };

  # Don't silently fail the switch job on a flaky hotspot.
  systemd.services.NetworkManager-wait-online.enable = false;

  # --- Compression swap for a 16-32GB laptop ------------------------------
  zramSwap.enable = true;

  # --- Nix GC / store hygiene --------------------------------------------
  nix.gc = {
    automatic = true;
    dates = "09:00";
    options = "--delete-older-than 14d";
  };

  # Discard unused NVMe blocks weekly.
  services.fstrim.enable = true;

  # --- Programs -----------------------------------------------------------
  programs = {
    zsh.shellInit = ''
      LOCALCOLOR=$'%{\e[1;32m%}'
    '';
    tmux.enable = true;
    # `light` + `video` group gives unprivileged brightness control.
    light.enable = true;
  };

  users.users.${me}.extraGroups = [
    "networkmanager"
    "video"
  ];

  # --- Home Manager -------------------------------------------------------
  home-manager.users.${me}.imports = [ ./home.nix ];

  # Don't bump this unless you know what you're doing; see
  # https://nixos.org/manual/nixos/stable/options.html#opt-system.stateVersion
  system.stateVersion = "24.05";
}
