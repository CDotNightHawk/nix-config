# Framework 13 AMD (Ryzen 7040 / AI 300 series) + Intel AX210 WiFi.
#
# This is the root module for the `framework` nixosConfiguration.
# Anything genuinely laptop- or host-specific lives here; everything
# reusable lives under ../../modules/nixos/.
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
    # Hardware (generated + hand-written tweaks)
    ./hardware-configuration.nix
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
    (modulesNixos + /xdg.nix)
    (modulesNixos + /zsh.nix)
    (modulesNixos + /shell-aliases.nix)
    (modulesNixos + /gc.nix)
    (modulesNixos + /locale.nix)

    # Niri + DMS + ly stack (replaces Plasma 6 / SDDM)
    (modulesNixos + /desktop/niri.nix)
    (modulesNixos + /desktop/dms.nix)
    (modulesNixos + /desktop/ly.nix)
    (modulesNixos + /desktop/sound.nix)
    (modulesNixos + /desktop/firefox.nix)

    # Sway as a Wayland fallback session — gives ly a second
    # `wayland-sessions/*.desktop` to offer, so if niri ever breaks
    # we still have a working compositor to log into.
    (modulesNixos + /desktop/sway.nix)

    # CUPS + cups-pk-helper + driver bundles + mDNS printer discovery.
    (modulesNixos + /services/printing.nix)

    # Security: doas only.
    (modulesNixos + /security.nix)

    # Containers / virt
    (modulesNixos + /virt/podman.nix)

    # SSH (system side). Allows root + me login via lib/keys/id_rsa.pub
    # and enables fail2ban. Drop this import on a laptop you don't
    # want sshd on.
    (modulesNixos + /ssh.nix)

    # Third-party
    inputs.night-nur.nixosModules.overlay
    inputs.lix-module.nixosModules.default
    inputs.sops-nix.nixosModules.sops
  ];

  # Use the latest mainline kernel — Framework 13 AMD benefits from
  # newer amdgpu / amd-pstate / fingerprint drivers.
  nighthawk.kernel = "latest";

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

  # power-profiles-daemon (do NOT also enable TLP).
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

  # --- Compression swap ---------------------------------------------------
  zramSwap.enable = true;

  # --- Nix GC -------------------------------------------------------------
  nix.gc = {
    automatic = true;
    dates = "09:00";
    options = "--delete-older-than 14d";
  };

  services.fstrim.enable = true;

  # --- Programs -----------------------------------------------------------
  programs = {
    zsh.shellInit = ''
      LOCALCOLOR=$'%{\e[1;32m%}'
    '';
    tmux.enable = true;
    # Brightness keys: brightnessctl is installed system-wide via
    # modules/nixos/desktop/niri.nix and DMS' niri preset already
    # binds the XF86MonBrightness* keys. Membership in the `video`
    # group lets brightnessctl poke the backlight without doas.
  };

  users.users.${me}.extraGroups = [
    "networkmanager"
    "video"
  ];

  # --- Home Manager -------------------------------------------------------
  home-manager.users.${me}.imports = [ ./home.nix ];

  # https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion
  # Do not change this.
  system.stateVersion = "24.05";
}
