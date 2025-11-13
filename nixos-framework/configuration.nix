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
  imports = [
    (r.extras + /shared-nix-settings.nix)
    (r.common-nixos + /cfg-misc.nix)
    (r.common-nixos + /cfg-home-manager.nix)
    (r.common-nixos + /cfg-common-system-packages.nix)
    (r.common-nixos + /cfg-linux-kernel.nix)
    (r.common-nixos + /cfg-ssh.nix)
    (r.common-nixos + /cfg-nix-settings.nix)
    (r.common-nixos + /cfg-my-user.nix)
    (r.common-nixos + /cfg-podman.nix)
    (r.common-nixos + /cfg-shell-aliases.nix)
    (r.common-nixos + /cfg-sudo-config.nix)
    (r.common-nixos + /cfg-auto-optimise.nix)
    (r.common-nixos + /cfg-xdg.nix)
    (r.common-nixos + /cfg-zsh.nix)
    (r.common-nixos + /cfg-delete-old-hm-profiles.nix)
    ./hardware-configuration.nix

    inputs.hax-nur.nixosModules.overlay
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
    extraModprobeConfig = ''
    options mt7925e disable_aspm=1
    '';
    tmp.cleanOnBoot = true;
    # normally disabled by minimal.nix
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

  users.users = {
    nighthawk = {
      description = "nighthawk";
      isNormalUser = true;
      uid = 1001;
      linger = true;
      shell = pkgs.bashInteractive;
    };
  };

  home-manager.users.${me}.imports = [ ./home.nix ];

  system.stateVersion = "24.05";
}
