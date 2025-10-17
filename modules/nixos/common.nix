# /etc/nixos/modules/nixos/common.nix
{ config, pkgs, ... }:
{
  # Timezone and locale
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Networking
  networking.networkmanager.enable = true;

  # KDE Plasma 6 Desktop Environment
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Sound with PipeWire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable other common services
  services.printing.enable = true;
  services.flatpak.enable = true;
  # programs.steam.enable = true;
  programs.zsh.enable = true;

  # Virtualization
  programs.virt-manager.enable = true;
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  # Enable flakes and the new nix command
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # System-wide packages (command-line tools, compilers, etc.)
  environment.systemPackages = with pkgs; [
    git
    cmake
    libvirt
    qemu
    libgcc
    gcc15
    cargo
    rustup
    gh
    screen
    minicom
    tio
    wineWowPackages.stable
    protonplus
    protonup-qt
    htop
    fastfetch
    ffmpeg_6-full
    cfssl
    inetutils
    lftp
    tree
  ];
}
