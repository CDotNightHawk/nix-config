{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.nighthawk.development;
in
{
  options.nighthawk.development = {
    enable = lib.mkEnableOption "the core development environment";
    cloud.enable = lib.mkEnableOption "cloud and infrastructure-as-code CLIs";
    containers.enable = lib.mkEnableOption "container development tools";
    kubernetes.enable = lib.mkEnableOption "Kubernetes development tools";
    languages.enable = lib.mkEnableOption "global language toolchains";
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      (with pkgs; [
        actionlint
        btop
        deadnix
        fd
        httpie
        jq
        just
        lazygit
        lsof
        mtr
        nh
        nil
        nix-output-monitor
        nix-tree
        nixd
        nixfmt
        procs
        ripgrep
        sd
        shellcheck
        shfmt
        statix
        yq-go
      ])
      ++ lib.optionals cfg.cloud.enable (
        with pkgs;
        [
          ansible
          ansible-lint
          awscli2
          azure-cli
          google-cloud-sdk
          opentofu
          pulumi-bin
          terraform
          terragrunt
        ]
      )
      ++ lib.optionals cfg.containers.enable (
        with pkgs;
        [
          dive
          docker-compose
          hadolint
          incus.client
          lazydocker
          trivy
        ]
      )
      ++ lib.optionals cfg.kubernetes.enable (
        with pkgs;
        [
          argocd
          fluxcd
          helmfile
          k9s
          kind
          krew
          kubectx
          kubectl
          kubernetes-helm
          kustomize
          stern
        ]
      )
      ++ lib.optionals cfg.languages.enable (
        with pkgs;
        [
          bun
          go
          nodejs_22
          pnpm
          rustup
          uv
        ]
      );

    programs = {
      atuin = {
        enable = true;
        enableZshIntegration = true;
        flags = [ "--disable-up-arrow" ];
      };
      direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
      fzf = {
        enable = true;
        enableZshIntegration = true;
        tmux.enableShellIntegration = true;
      };
      lazygit.enable = true;
      starship = {
        enable = true;
        enableZshIntegration = true;
        settings = {
          add_newline = false;
          format = lib.concatStrings [
            "$directory"
            "$git_branch$git_status"
            "$nix_shell"
            "$kubernetes"
            "$aws"
            "$cmd_duration"
            "$line_break"
            "$character"
          ];
          aws.disabled = false;
          kubernetes.disabled = false;
          nix_shell.disabled = false;
        };
      };
      zoxide = {
        enable = true;
        enableZshIntegration = true;
      };
    };
  };
}
