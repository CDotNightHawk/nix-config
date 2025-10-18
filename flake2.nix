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
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
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
  };

  outputs = 
    { 
      self, 
      nixpkgs, 
      disko,
      home-manager, 
      sops-nix,
      lix,
      lix-module,
      ... 
    }@inputs:
    let
      r = {
        root = ./.;
        common-nixos = ./common-nixos;
        common-home = ./common-home;
        extras = ./extras;
      };
      pkgs = import nixpkgs {
        inherit system;
	config.allowUnfree = false;
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
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
      treefmtEval = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        treefmt-nix.lib.evalModule pkgs ./treefmt.nix
      );
    in
    {
      nixosConfigurations = {
        framework = nixpkgs.lib.nixosSystem {
          inherit system;
	  inherit pkgs;
          specialArgs = { inherit inputs; };
          modules = [
	    disko.nixosModules.disko
            ./framework/configuration.nix
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.nighthawk = import ./users/nighthawk/home.nix;
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
	    sops-nix.nixosModules.sops
          ];
        };
      };
      formatter.${system} = pkgs.nixfmt-tree;
    };
}
