# /etc/nixos/flake.nix
{
  description = "Nighthawk's NixOS Flake Configuration";

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
    };
  };

  outputs = 
    { 
      self, 
      nixpkgs, 
      disko,
      home-manager, 
      sops-nix,
      ... 
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
	config.allowUnfree = false;
      };
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
