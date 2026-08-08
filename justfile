set shell := ["bash", "-euo", "pipefail", "-c"]

default: check

fmt:
    nix fmt

lint:
    statix check .
    deadnix --fail .

check:
    nix flake check --show-trace

eval host="framework":
    nix eval ".#nixosConfigurations.{{host}}.config.system.build.toplevel.drvPath" --raw --show-trace

build host="framework":
    nom build ".#nixosConfigurations.{{host}}.config.system.build.toplevel" --no-link --show-trace

switch host="framework":
    nh os switch . --hostname "{{host}}"

update:
    nix flake update
    nix flake check --show-trace
