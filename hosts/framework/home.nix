# Home-manager root for the framework host.
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
    (modulesHome + /desktop/chat.nix)
    (modulesHome + /desktop/apps.nix)
    (modulesHome + /editors/nixvim.nix)
    (modulesHome + /tooling/devops.nix)
  ];

  programs = {
    man.enable = false;
    nix-index.enable = lib.mkForce false;
    zsh.initContent = ''
      ######################################################################
      # begin hosts/framework/home.nix

      LOCALCOLOR=$'%{\e[1;32m%}'

      # end hosts/framework/home.nix
    '';
  };
}
