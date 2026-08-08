{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.nightpkg.packages.enableExtra = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Install workstation-oriented diagnostics and documentation.";
  };

  config.environment.systemPackages =
    (with pkgs; [
      btop
      curl
      file
      git
      lsof
      psmisc
      rsync
      tree
      unzip
      wget
      xxd
      zip
    ])
    ++ lib.optionals config.nightpkg.packages.enableExtra (
      with pkgs;
      [
        binutils
        nixpkgs-manual
        pciutils
        usbutils
      ]
    );
}
