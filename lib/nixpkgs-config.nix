{ pkgs, inputs }:

# this is to be set as a NIXPKGS_CONFIG env var
# but this should also go in /etc or something
''
  {
    allowUnfree = true;

    packageOverrides = pkgs: {
      nightpkg = import ${inputs.night-nur} { inherit pkgs; };
    };
  }
''
