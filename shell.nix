{ pkgs }:

pkgs.mkShellNoCC {
  packages = with pkgs; [
    actionlint
    age
    deadnix
    git
    just
    nh
    nil
    nix-output-monitor
    nixd
    nixfmt
    pre-commit
    shellcheck
    sops
    statix
    treefmt
  ];
}
