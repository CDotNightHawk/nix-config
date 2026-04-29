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
    (modulesHome + /linux.nix)
    (modulesHome + /core.nix)
    (modulesHome + /sops.nix)
    (modulesHome + /desktop/niri-dms.nix)
    (modulesHome + /editors/nixvim.nix)
    (modulesHome + /tooling/devops.nix)
  ];

  programs.zsh.initContent = ''
    ######################################################################
    # begin hosts/workstation/home.nix

    LOCALCOLOR=$'%{\e[1;36m%}'

    # end hosts/workstation/home.nix
  '';
}
