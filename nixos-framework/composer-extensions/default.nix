{
  pkgs ? import <nixpkgs> { },
}:

let
  inherit (pkgs) fetchFromGitHub;
  getWMExtension = import ../func-get-wm-extension.nix { inherit pkgs; };
  wrapComposerPackage = pkgs.callPackage ./wrap-composer-package.nix { };
  mkExtensionWithComposer = file: pkgs.callPackage file { inherit wrapComposerPackage; };
  mkMWExtension =
    {
      pname,
      src,
      vendorHash,
      composerLock,
      branch ? null,
    }:
    pkgs.callPackage ./func-mk-mediawiki-extension.nix {
      inherit
        pname
        src
        vendorHash
        composerLock
        branch
        ;
    };
in
{
  QRLite = mkMWExtension {
    pname = "QRLite";
    src = fetchFromGitHub {
      owner = "gesinn-it";
      repo = "QRLite";
      rev = "28b0e65b41d56887b98888a993b238e3287295de";
      hash = "sha256-fh9F7eC7sfVriNhkWsk3+r/ItHj4+dV+MxnMwVvOCrM=";
    };
    branch = "master";
    vendorHash = "sha256-gc203AgcT//+Lhr9gBh53jf7kRKem1XMsSVTkzgGubo=";
    composerLock = ./qrlite.lock;
  };
  TemplateStyles = mkMWExtension rec {
    pname = "TemplateStyles";
    src = getWMExtension {
      name = pname;
      rev = "adea53c1229674175275681eed9de26bdd611cfc";
      hash = "sha256-roR7ZzCh+6kg8XCd5VW1erjaWoy642cnPp/ezLVqs7A=";
    };
    vendorHash = "sha256-CQEB7NRj8YhHdVf4MLZuWk1vcvVXSZHOscOd5F7uO2Q=";
    composerLock = ./templatestyles.lock;
  };
  Variables = mkMWExtension rec {
    pname = "Variables";
    src = getWMExtension {
      name = pname;
      rev = "2b5963315402ec912955fd7f1256716b46953866";
      hash = "sha256-5ZFiu+eBULOdxpIN4JSboRtV4CV+nsSFCNEkZRmMji0=";
    };
    vendorHash = "sha256-/udvDpzwLZmqkxHK1N2dM7znsvEwTWzA+keoCmM0gMY=";
    composerLock = ./variables.lock;
  };
}
