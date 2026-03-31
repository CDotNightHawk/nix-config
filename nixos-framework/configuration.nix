# Inspired by https://codeberg.org/ihaveahax/nix-config
{
  config,
  lib,
  pkgs,
  me,
  r,
  inputs,
  modulesPath,
  ...
}:

{
  imports = with r; [
    (extras + /shared-nix-settings.nix)
    (common-nixos + /cfg-misc.nix)
    (common-nixos + /cfg-home-manager.nix)
    (common-nixos + /cfg-common-system-packages.nix)
    (common-nixos + /cfg-linux-kernel.nix)
    (common-nixos + /cfg-ssh.nix)
    (common-nixos + /cfg-nix-settings.nix)
    (common-nixos + /cfg-my-user.nix)
    (common-nixos + /cfg-podman.nix)
    (common-nixos + /cfg-shell-aliases.nix)
    (common-nixos + /cfg-sudo-config.nix)
    (common-nixos + /cfg-auto-optimise.nix)
    (common-nixos + /cfg-xdg.nix)
    (common-nixos + /cfg-zsh.nix)
    (common-nixos + /cfg-security.nix)
    (common-nixos + /cfg-delete-old-hm-profiles.nix)
    ./hardware-configuration.nix

    inputs.night-nur.nixosModules.overlay
    inputs.lix-module.nixosModules.default
    inputs.sops-nix.nixosModules.sops
    "${modulesPath}/profiles/minimal.nix"
  ];

  #sops = {
  #  defaultSopsFile = r.root + /secrets/framework/default.yaml;
  #  age = {
  #    keyFile = "/etc/sops-key.txt";
  #    generateKey = true;
  #  };
  #};

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    
    extraModprobeConfig = ''
      options mt7925e disable_aspm=1
    '';
    tmp.cleanOnBoot = true;
    enableContainers = lib.mkForce true;
  };

  zramSwap.enable = true;

  networking = {
    domain = "framework.nanofox.dev";
    hostName = "framework";
    firewall.allowedTCPPorts = [
      80
      443
    ];
  };

  services = {
    tailscale.enable = true;
    fprintd.enable = true;
    do-agent.enable = true;
    openssh.settings = {
      X11Forwarding = lib.mkForce false;
      PasswordAuthentication = false;
    };
  };

  environment.systemPackages = with pkgs; [
  ];

  programs = {
    zsh = {
      shellInit = ''
        LOCALCOLOR=$'%{\e[1;32m%}'
      '';
    };
    tmux.enable = true;
  };

  nix.gc = {
    automatic = true;
    options = "--delete-old";
    dates = "09:00";
  };

  home-manager.users.${me}.imports = [ ./home.nix ];

  system.stateVersion = "24.05";
}
