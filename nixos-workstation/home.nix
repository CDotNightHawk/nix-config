# Home-manager root for the workstation host.
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

  programs.zsh.initContent = ''
    ######################################################################
    # begin nixos-workstation/home.nix

    LOCALCOLOR=$'%{\e[1;36m%}'

    # end nixos-workstation/home.nix
  '';
}
