# Inspired by https://codeberg.org/ihaveahax/nix-config
{
  config,
  lib,
  me,
  r,
  inputs,
  my-inputs,
  ...
}:

let
  homedir = config.users.users.${me}.home;
in
{
  imports = [ my-inputs.home-manager-module ];

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit inputs my-inputs r; };

    users.${me} = _: {
      # the order of this matters
      imports = [ ];

      home = {
        username = me;
        homeDirectory = homedir;
      };

      programs.home-manager.enable = lib.mkForce false;
      fonts.fontconfig.enable = lib.mkForce false;
      home.file.".zshenv".enable = false;

      # cannot be set when useGlobalPkgs is true
      nixpkgs.config = lib.mkForce null;
    };

    users.root = _: {
      imports = [ (r.modulesHome + /core-root.nix) ];

      home = {
        username = "root";
        homeDirectory = config.users.users.root.home;
      };

      programs.home-manager.enable = lib.mkForce false;
      home.file.".zshenv".enable = false;

      # cannot be set when useGlobalPkgs is true
      nixpkgs.config = lib.mkForce null;
    };
  };
}
