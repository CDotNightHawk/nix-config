# Inspired by https://codeberg.org/ihaveahax/nix-config
# ~/nix-config/flake.nix
{
  description = "Nighthawk's NixOS Flake Configuration";

  nixConfig = {
    extra-substituters = [
      "https://nighthawk.cachix.org"
      # Lix's binary cache. Without this the lix-module input forces a
      # ~10-minute clang/ninja build of Lix on every fresh machine.
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

    # Declarative disk partitioning (used by the workstation host).
    disko = {
      url = "git+https://github.com/nix-community/disko";
      inputs.nixpkgs.follows = "nixos-unstable";
    };

    # niri Wayland compositor + Nix-typed config.
    niri = {
      url = "git+https://github.com/sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixos-unstable";
    };

    # DankMaterialShell (QuickShell-based niri shell from danklinux.com).
    dms = {
      url = "git+https://github.com/AvengeMedia/DankMaterialShell?ref=stable";
      inputs.nixpkgs.follows = "nixos-unstable";
    };

    # dgop is the system-monitor backend DMS uses. It's only in
    # nixpkgs >= 26.05; on the pinned `nixos-unstable` it isn't
    # available yet, so we fetch it from upstream.
    dgop = {
      url = "git+https://github.com/AvengeMedia/dgop";
      inputs.nixpkgs.follows = "nixos-unstable";
    };

    # dsearch (a.k.a. danksearch): bleve-backed file index DMS' launcher
    # uses for the file-search panel. Without this DMS' System Check
    # flags it as "Not installed".
    dsearch = {
      url = "git+https://github.com/AvengeMedia/danksearch";
      inputs.nixpkgs.follows = "nixos-unstable";
    };

    # NixVim: declarative Neovim config that fails at flake-check time
    # if the config is wrong. Way more pleasant than reading raw .lua
    # error messages on first boot.
    nixvim = {
      url = "git+https://github.com/nix-community/nixvim";
      inputs.nixpkgs.follows = "nixos-unstable";
    };

    # nix-flatpak: declarative Flathub app management. Lets us pin the
    # set of installed flatpaks in the flake the same way we pin nix
    # packages, instead of relying on `flatpak install` muscle memory.
    # See modules/nixos/apps/flatpak.nix.
    nix-flatpak = {
      url = "git+https://github.com/gmodena/nix-flatpak?ref=main";
    };

    # spicetify-nix: declarative Spotify customisation via spicetify-cli.
    # Provides themes, extensions (adblock, hidePodcasts, …), and custom
    # apps as Nix options.  See modules/home/desktop/spicetify.nix.
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
      lanzaboote,
      night-nur,
      lix,
      lix-module,
      sops-nix,
      disko,
      niri,
      dms,
      dgop,
      nixvim,
      spicetify-nix,
      ...
    }:
    let
      # Path-record. Use this in module imports so paths are anchored
      # to the flake root regardless of which subdir a module lives in.
      # NB: do NOT name a field `lib` — module function
      # args expose `lib = nixpkgs.lib`, and `with r;` can't shadow
      # function arguments, so `r.lib` would be unreachable inside a
      # module body.
      r = {
        root = ./.;
        hosts = ./hosts;
        modulesNixos = ./modules/nixos;
        modulesHome = ./modules/home;
        libs = ./lib;
        secrets = ./secrets;
      };
      mkHost =
        hostPath:
        let
          me = "nighthawk";
          system = "x86_64-linux";
        in
        nixos-unstable.lib.nixosSystem {
          inherit system;
          specialArgs = mkSpecialArgs me system;
          modules = [ hostPath ];
        };
      mkSpecialArgs = (
        me: system: {
          inherit me inputs r;
          my-inputs = {
            # putting this in modules/nixos/home-manager.nix causes an infinite recursion error
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
        framework = mkHost ./hosts/framework;
        workstation = mkHost ./hosts/workstation;
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
