{
  description = "NightHawk's NixOS systems";

  nixConfig = {
    extra-substituters = [
      "https://nighthawk.cachix.org"
      "https://cache.lix.systems"
    ];
    extra-trusted-public-keys = [
      "nighthawk.cachix.org-1:+Ppa/mjYFZFhMz95oSQNRJo+J9koACCy/4GtcautuYc="
      "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
    ];
  };

  inputs = {
    nixos-unstable.url = "git+https://github.com/NixOS/nixpkgs?ref=nixos-unstable";

    home-manager = {
      url = "git+https://github.com/nix-community/home-manager?ref=master";
      inputs.nixpkgs.follows = "nixos-unstable";
    };
    treefmt-nix = {
      url = "git+https://github.com/numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixos-unstable";
    };
    sops-nix = {
      url = "git+https://github.com/Mic92/sops-nix";
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
    lix = {
      url = "github:lix-project/lix";
      flake = false;
    };
    lix-module = {
      url = "git+https://git.lix.systems/lix-project/nixos-module?ref=main";
      inputs.nixpkgs.follows = "nixos-unstable";
      inputs.lix.follows = "lix";
    };
    disko = {
      url = "git+https://github.com/nix-community/disko";
      inputs.nixpkgs.follows = "nixos-unstable";
    };
    niri = {
      url = "git+https://github.com/sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixos-unstable";
    };
    dms = {
      url = "git+https://github.com/AvengeMedia/DankMaterialShell?ref=stable";
      inputs.nixpkgs.follows = "nixos-unstable";
    };
    dgop = {
      url = "git+https://github.com/AvengeMedia/dgop";
      inputs.nixpkgs.follows = "nixos-unstable";
    };
    dsearch = {
      url = "git+https://github.com/AvengeMedia/danksearch";
      inputs.nixpkgs.follows = "nixos-unstable";
    };
    nixvim = {
      url = "git+https://github.com/nix-community/nixvim";
      inputs.nixpkgs.follows = "nixos-unstable";
    };
    nix-flatpak.url = "git+https://github.com/gmodena/nix-flatpak?ref=main";
    spicetify-nix = {
      url = "git+https://github.com/Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixos-unstable";
    };
  };

  outputs =
    inputs@{
      self,
      nixos-unstable,
      home-manager,
      treefmt-nix,
      night-nur,
      ...
    }:
    let
      inherit (nixos-unstable) lib;
      defaultUser = "nighthawk";
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      r = {
        root = ./.;
        hosts = ./hosts;
        profilesNixos = ./profiles/nixos;
        profilesHome = ./profiles/home;
        modulesNixos = ./modules/nixos;
        modulesHome = ./modules/home;
        libs = ./lib;
        secrets = ./secrets;
      };
      forAllSystems = lib.genAttrs systems;
      mkSpecialArgs = system: {
        inherit inputs r;
        me = defaultUser;
        my-inputs = {
          home-manager-module = home-manager.nixosModules.home-manager;
          night-nur = night-nur.packages.${system};
        };
      };
      mkHost =
        {
          host,
          system ? "x86_64-linux",
        }:
        lib.nixosSystem {
          inherit system;
          specialArgs = mkSpecialArgs system;
          modules = [ host ];
        };
      nixosConfigurations = {
        framework = mkHost { host = ./hosts/framework; };
        workstation = mkHost { host = ./hosts/workstation; };
        server = mkHost { host = ./hosts/server; };
      };
      treefmtEval = forAllSystems (
        system: treefmt-nix.lib.evalModule nixos-unstable.legacyPackages.${system} ./treefmt.nix
      );
      mkEvaluationCheck =
        pkgs: name: configuration:
        pkgs.runCommand "nixos-${name}-evaluation"
          {
            drvPath = builtins.unsafeDiscardStringContext configuration.config.system.build.toplevel.drvPath;
          }
          ''
            mkdir -p "$out"
            printf '%s\n' "$drvPath" > "$out/drv-path"
          '';
    in
    {
      inherit nixosConfigurations;

      nixosModules = {
        default = import ./profiles/nixos/base.nix;
        base = import ./profiles/nixos/base.nix;
        client = import ./profiles/nixos/client.nix;
        incus = import ./modules/nixos/virt/incus.nix;
        server = import ./profiles/nixos/server.nix;
      };

      homeManagerModules = {
        client = import ./profiles/home/client.nix;
        development = import ./modules/home/tooling/development.nix;
      };

      devShells = forAllSystems (
        system:
        let
          pkgs = nixos-unstable.legacyPackages.${system};
        in
        {
          default = import ./shell.nix { inherit pkgs; };
        }
      );

      formatter = forAllSystems (system: treefmtEval.${system}.config.build.wrapper);

      checks = forAllSystems (
        system:
        let
          pkgs = nixos-unstable.legacyPackages.${system};
          hostChecks = lib.mapAttrs' (
            name: configuration: lib.nameValuePair "nixos-${name}" (mkEvaluationCheck pkgs name configuration)
          ) nixosConfigurations;
        in
        {
          formatting = treefmtEval.${system}.config.build.check self;
        }
        // lib.optionalAttrs (system == "x86_64-linux") hostChecks
      );
    };
}
