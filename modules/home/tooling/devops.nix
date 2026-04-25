# Sysadmin / devops / coding tooling for the home profile.
#
# Anything that's "I'm working on real systems and want sane defaults".
# Stuff that's specific to a single project belongs in a flake-based
# devshell, not here.
{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [
    # --- Cloud / IaC ---------------------------------------------------
    awscli2
    google-cloud-sdk
    azure-cli
    terraform
    terragrunt
    opentofu
    ansible
    ansible-lint
    pulumi-bin

    # --- Kubernetes ----------------------------------------------------
    kubectl
    kubectx
    kubernetes-helm
    helmfile
    k9s
    stern
    kustomize
    krew
    minikube
    kind
    fluxcd
    argocd

    # --- Containers / build --------------------------------------------
    docker-compose
    dive
    hadolint
    trivy

    # --- Networking / debug --------------------------------------------
    dnsutils
    bind.dnsutils
    nmap
    mtr
    iperf3
    socat
    netcat-openbsd
    tcpdump
    httpie
    curl
    wget
    rsync

    # --- Observability -------------------------------------------------
    btop
    htop
    iotop
    iftop
    bandwhich
    lsof
    procs

    # --- Editors / TUI -------------------------------------------------
    helix
    lazygit
    lazydocker

    # --- Language toolchains -------------------------------------------
    go
    rustup
    uv # python project / env manager
    nodejs_22
    pnpm
    bun

    # --- Shell QoL -----------------------------------------------------
    starship
    direnv
    nix-direnv
    atuin
    zoxide
    fzf
    ripgrep
    fd
    sd
    jq
    yq-go
    just
  ];

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    atuin = {
      enable = true;
      enableZshIntegration = true;
      flags = [ "--disable-up-arrow" ];
    };
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
    fzf = {
      enable = true;
      enableZshIntegration = true;
      tmux.enableShellIntegration = true;
    };
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
        kubernetes.disabled = false;
        aws.disabled = false;
        nix_shell.disabled = false;
      };
    };
    lazygit.enable = true;
  };
}
