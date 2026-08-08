{ pkgs, ... }:

{
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "nrvl" ''
      exec nixos-rebuild -v -L "$@"
    '')
  ];
}
