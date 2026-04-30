# Home-manager-side sops-nix configuration.
#
# Prereqs on a fresh machine:
#   mkdir -p ~/.config/sops/age && chmod 700 ~/.config/sops/age
#   age-keygen -o ~/.config/sops/age/keys.txt
#   chmod 600 ~/.config/sops/age/keys.txt
#
# Then copy the public key from `age-keygen -y ~/.config/sops/age/keys.txt`
# into .sops.yaml and (re-)create the encrypted payloads under
# secrets/keys/ — see the comments in this file for the schema each
# secret expects.
#
# This module degrades gracefully in two ways:
#
#   1. If the user hasn't bootstrapped ~/.config/sops/age/keys.txt yet,
#      the systemd `sops-nix` user unit's `ExecCondition` returns
#      non-zero and systemd marks the unit *skipped* (not failed), so
#      home-manager activation succeeds. See `Service.ExecCondition`
#      below.
#
#   2. If the encrypted source files in secrets/keys/ haven't been
#      created yet (e.g. fresh checkout, lost private key), the
#      `sops.secrets` declarations are simply omitted at evaluation
#      time. That keeps `nix flake check` green and avoids the
#      "Path 'secrets/keys/...' does not exist in Git repository"
#      error from importing a missing path into the store.
{
  config,
  lib,
  pkgs,
  r,
  inputs,
  ...
}:

let
  # Anchor each encrypted file once so the rest of the module can
  # reference it without re-typing the path. `pathExists` runs at
  # eval time against the (flake-locked) source tree, which is exactly
  # the granularity we want — once the file is committed, the next
  # `home-manager switch` picks it up automatically.
  githubSecretsFile = r.root + /secrets/keys/git/github.yaml;
  hasGithubSecrets = builtins.pathExists githubSecretsFile;
in
{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  }
  // lib.optionalAttrs hasGithubSecrets {
    defaultSopsFile = githubSecretsFile;

    # Schema for secrets/keys/git/github.yaml (sops --age <pubkey>):
    #   github_token: <PAT with repo + workflow scopes>
    #   github_ssh_key: |
    #     -----BEGIN OPENSSH PRIVATE KEY-----
    #     ...
    #     -----END OPENSSH PRIVATE KEY-----
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

  # Skip the sops activation unit when the user hasn't bootstrapped
  # ~/.config/sops/age/keys.txt yet. systemd's ExecCondition treats a
  # non-zero exit as "skipped" (the unit is marked inactive, not
  # failed), so home-manager activation succeeds either way. The
  # bootstrap commands at the top of this file recover the missing
  # key; once it's in place the next `home-manager switch` re-runs
  # the unit normally because ExecCondition exits 0. See
  # systemd.exec(5) for the full state-machine semantics.
  systemd.user.services.sops-nix.Service.ExecCondition =
    "${pkgs.coreutils}/bin/test -f ${config.home.homeDirectory}/.config/sops/age/keys.txt";

  # Print a one-line warning during home-manager activation when the
  # keyfile is missing, so the bootstrap step is obvious in the
  # `home-manager switch` output. Doesn't fail activation — just
  # nudges the user toward `age-keygen`. Pure shell, no nix
  # interpolation that depends on the file existing.
  home.activation.sopsKeyfileWarning = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -f "$HOME/.config/sops/age/keys.txt" ]; then
      echo ""
      echo "  [sops-nix] WARNING: $HOME/.config/sops/age/keys.txt missing."
      echo "  [sops-nix] Encrypted secrets will NOT be installed until you run:"
      echo "  [sops-nix]   mkdir -p $HOME/.config/sops/age && chmod 700 $HOME/.config/sops/age"
      echo "  [sops-nix]   age-keygen -o $HOME/.config/sops/age/keys.txt"
      echo "  [sops-nix]   chmod 600 $HOME/.config/sops/age/keys.txt"
      echo ""
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
