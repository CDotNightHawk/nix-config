{
  config,
  lib,
  pkgs,
  r,
  inputs,
  ...
}:

let
  githubSecretsFile = r.root + /secrets/keys/git/github.yaml;
  hasGithubSecrets = builtins.pathExists githubSecretsFile;
  ageKeyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
in
{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  sops = {
    age.keyFile = ageKeyFile;
  }
  // lib.optionalAttrs hasGithubSecrets {
    defaultSopsFile = githubSecretsFile;
    secrets.github_ssh_key = {
      path = "${config.home.homeDirectory}/.ssh/id_github";
      mode = "0400";
      sopsFile = githubSecretsFile;
    };
    secrets.github_token = {
      format = "yaml";
      sopsFile = githubSecretsFile;
    };
  };

  # Missing bootstrap keys skip decryption without failing activation.
  systemd.user.services.sops-nix.Service.ExecCondition =
    "${pkgs.coreutils}/bin/test -f ${ageKeyFile}";

  home.activation.sopsKeyfileWarning = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -f "${ageKeyFile}" ]; then
      echo "[sops-nix] ${ageKeyFile} is missing; encrypted secrets were skipped."
    fi
  '';

  programs.ssh = {
    enable = true;
    matchBlocks."github.com" = {
      user = "git";
      identityFile = "${config.home.homeDirectory}/.ssh/id_github";
      identitiesOnly = true;
    };
  };
}
