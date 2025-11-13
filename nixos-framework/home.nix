# Inspired by https://codeberg.org/ihaveahax/nix-config
{
  config,
  lib,
  pkgs,
  r,
  ...
}:

{
  imports = [
    (r.common-home + /linux.nix)
    (r.common-home + /core.nix)
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops.defaultSopsFile = r.root + /framework/secrets/keys/git/github.yaml;
  sops.age.keyFile = "/home/nighthawk/.config/sops/age/keys.txt";
  sops.secrets.github_ssh_key = {
    path = "${config.home.homeDirectory}/.ssh/id_github";
    mode = "0400";
  };
  sops.secrets.github_token = {
    format = "yaml";
    sopsFile = r.root + /framework/secrets/keys/git/github.yaml;
  };
  programs.ssh = {
    extraConfig = ''
      Host github.com
        User git
        IdentityFile ${config.home.homeDirectory}/.ssh/id_github
        IdentitiesOnly yes
    '';
  };

  programs = {
    man.enable = false;
    nix-index.enable = lib.mkForce false;
    zsh = {
      initContent = ''
        ######################################################################
        # begin nixos-framework/home.nix

        LOCALCOLOR=$'%{\e[1;32m%}'

        # end nixos-framework/home.nix
      '';
    };
  };
}
