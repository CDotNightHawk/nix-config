# Home-manager side of the framework host.
{
  config,
  lib,
  pkgs,
  r,
  inputs,
  ...
}:

{
  imports = with r; [
    (common-home + /linux.nix)
    (common-home + /core.nix)
    (common-home + /cfg-sops.nix)
    (common-home + /cfg-niri-dms.nix)
    (common-home + /cfg-nixvim.nix)
    (common-home + /cfg-devops.nix)
  ];

  programs = {
    man.enable = false;
    nix-index.enable = lib.mkForce false;
    zsh.initContent = ''
      ######################################################################
      # begin nixos-framework/home.nix

      LOCALCOLOR=$'%{\e[1;32m%}'

      # end nixos-framework/home.nix
    '';
  };
}
