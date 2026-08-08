_: {
  projectRootFile = "flake.nix";
  programs.nixfmt.enable = true;

  # Nixfmt changes whitespace inside the embedded Vifm configuration.
  settings.formatter.nixfmt.excludes = [ "modules/home/vifm.nix" ];
}
