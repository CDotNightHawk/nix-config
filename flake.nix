# Inspired by https://codeberg.org/ihaveahax/nix-config
# ~/nix-config/flake.nix
{
  description = "Nighthawk's NixOS Flake Configuration";

  nixConfig = {
    extra-substituters = [
      "https://nighthawk.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nighthawk.cachix.org-1:+Ppa/mjYFZFhMz95oSQNRJo+J9koACCy/4GtcautuYc="
    ];
  };

  inputs = {
    nixos-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixos-unstable";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixos-unstable";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixos-unstable";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.3";
      inputs.nixpkgs.follows = "nixos-unstable";
    };
    night-nur = {
      url = "github:CDotNightHawk/nur-packages/staging";
      inputs.nixpkgs.follows = "nixos-unstable";
      inputs.treefmt-nix.follows = "treefmt-nix";
    };
    # https://git.lix.systems/lix-project/lix/issues/917
    lix = {
      url = "github:lix-project/lix";
      flake = false;
    };
    lix-module = {
      url = "git+https://git.lix.systems/lix-project/nixos-module?ref=main";
      inputs.nixpkgs.follows = "nixos-unstable";
      inputs.lix.follows = "lix";
    };
  };

  outputs =
    inputs@{
      self,
      nixos-unstable,
      home-manager,
      treefmt-nix,
      lanzaboote,
      night-nur,
      lix,
      lix-module,
      sops-nix,
    }:
    let
      r = {
        root = ./.;
        common-nixos = ./common-nixos;
        common-home = ./common-home;
        extras = ./extras;
      };
      mkSpecialArgs = (
        me: system: {
          inherit me inputs r;
          my-inputs = {
            # putting this in cfg-home-manager.nix causes an infinite recursion error
            home-manager-module = home-manager.nixosModules.home-manager;
            night-nur = night-nur.outputs.packages.${system};
          };
        }
      );
      # mainly for treefmt-nix / devShells
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = f: nixos-unstable.lib.genAttrs systems (system: f system);
      treefmtEval = forAllSystems (
        system:
        let
          pkgs = import nixos-unstable { inherit system; };
        in
        treefmt-nix.lib.evalModule pkgs ./treefmt.nix
      );
    in
    {
      nixosConfigurations = {
        "framework" = nixos-unstable.lib.nixosSystem (
          let
            me = "nighthawk";
            system = "x86_64-linux";
          in
          {
            inherit system;
            specialArgs = mkSpecialArgs me system;
            modules = [ ./nixos-framework/configuration.nix ];
          }
        );
      };

      devShells.x86_64-linux.default = import ./shell.nix {
        pkgs = import nixos-unstable { system = "x86_64-linux"; };
      };

      formatter = forAllSystems (system: treefmtEval.${system}.config.build.wrapper);
      checks = forAllSystems (system: {
        formatting = treefmtEval.${system}.config.build.check self;
      });
    };
}
