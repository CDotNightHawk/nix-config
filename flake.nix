# Inspired by https://codeberg.org/ihaveahax/nix-config
# ~/nix-config/flake.nix
{
  description = "Nighthawk's NixOS Flake Configuration";

  nixConfig = {
    extra-substituters = [
      "https://nighthawk.cachix.org"
    ];#"https://attic.nanofox.dev/cdotnighthawk"
    extra-trusted-public-keys = [
      "nighthawk.cachix.org-1:+Ppa/mjYFZFhMz95oSQNRJo+J9koACCy/4GtcautuYc="
    ];
  };

  inputs = {
    nixos-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      # to fix some dependency of keepassxc
      inputs.nixpkgs.follows = "nixos-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixos-unstable";
    };
    nixos-apple-silicon = {
      url = "github:tpwrules/nixos-apple-silicon";
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
      url = "github:nix-community/lanzaboote/v0.4.2";
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
      #url = "git+https://git.lix.systems/lix-project/nixos-module?ref=release-2.93";
      url = "git+https://git.lix.systems/lix-project/nixos-module?ref=main";
      inputs.nixpkgs.follows = "nixos-unstable";
      inputs.lix.follows = "lix";
    };
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixos-unstable,
      home-manager,
      nixos-apple-silicon,
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
            home-manager-module =
              if (system == "aarch64-darwin" || system == "x86_64-darwin") then
                home-manager.darwinModules.home-manager
              else
                home-manager.nixosModules.home-manager;
            night-nur = night-nur.outputs.packages.${system};
          };
        }
      );
      # these next ones are mainly for treefmt-nix
      systems = [
        "x86_64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-darwin"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
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
      darwinConfigurations = {
        # MacBook Air M2
        "nightair" = nix-darwin.lib.darwinSystem (
          let
            me = "nighthawk";
            system = "aarch64-darwin";
          in
          rec {
            inherit system;

            specialArgs = mkSpecialArgs me system;

            modules = [ ./nix-darwin-alphinaud/darwin-configuration.nix ];
          }
        ); # NightAir
      };

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
        ); # framework

        "workstation" = nixos-unstable.lib.nixosSystem (
          let
            me = "nighthawk";
            system = "x86_64-linux";
          in
          {
            inherit system;

            specialArgs = mkSpecialArgs me system;

            modules = [ ./nixos-workstation/configuration.nix ];
          }
        ); # workstation
      }; # nixosConfigurations

      devShells.x86_64-linux.default = import ./shell.nix {
        pkgs = import nixos-unstable { system = "x86_64-linux"; };
      };

      packages = {
        x86_64-linux =
          let
            pkgs = import nixos-unstable { system = "x86_64-linux"; };
          in
          rec {
            default = all-systems;
            all-systems = pkgs.callPackage ./extras/deriv-all-systems.nix {
              flakeConfigurations = {
                nixos-framework = self.nixosConfigurations.framework.config.system.build.toplevel;
                nixos-workstation = self.nixosConfigurations.workstation.config.system.build.toplevel;
              };
              flakeInputs = self.inputs;
            };
            more-stuff = pkgs.callPackage ./extras/deriv-all-systems.nix {
              flakeConfigurations = {
                nixos-framework = self.nixosConfigurations.framework.config.system.build.toplevel;
                nixos-workstation = self.nixosConfigurations.workstation.config.system.build.toplevel;
                iso = iso;
              };
              flakeInputs = self.inputs;
            };
            iso = pkgs.callPackage ./extras/deriv-iso.nix { nixosSystem = self.nixosConfigurations.liveimage; };
          };

        aarch64-darwin =
          let
            pkgs = import nixos-unstable { system = "aarch64-darwin"; };
          in
          rec {
            default = all-systems;
            all-systems = pkgs.callPackage ./extras/deriv-all-systems.nix {
              flakeConfigurations = {
                nix-darwin-alphinaud = self.darwinConfigurations.alphinaud.system;
              };
              flakeInputs = self.inputs;
            };
          };
      };

      formatter = forAllSystems (system: treefmtEval.${system}.config.build.wrapper);
      checks = forAllSystems (system: {
        formatting = treefmtEval.${system}.config.build.check self;
      });
    };
  };
}