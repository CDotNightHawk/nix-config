# Home-manager-side sops-nix configuration.
#
# Prereqs on a fresh machine:
#   mkdir -p ~/.config/sops/age
#   age-keygen -o ~/.config/sops/age/keys.txt
#   chmod 600 ~/.config/sops/age/keys.txt
#
# Then copy the public key from `age-keygen -y ~/.config/sops/age/keys.txt`
# into .sops.yaml and re-encrypt any secrets that should be accessible
# from this host with `sops updatekeys secrets/keys/**/*.yaml`.
{
  config,
  lib,
  pkgs,
  r,
  inputs,
  ...
}:

{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  sops = {
    defaultSopsFile = r.root + /secrets/keys/git/github.yaml;
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

    secrets.github_ssh_key = {
      path = "${config.home.homeDirectory}/.ssh/id_github";
      mode = "0400";
    };

    secrets.github_token = {
      format = "yaml";
      sopsFile = r.root + /secrets/keys/git/github.yaml;
    };
  };

  programs.ssh = {
    enable = true;
    matchBlocks."github.com" = {
      user = "git";
      identityFile = "${config.home.homeDirectory}/.ssh/id_github";
      identitiesOnly = true;
    };
  };
}
