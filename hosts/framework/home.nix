{
  lib,
  r,
  ...
}:

{
  imports = [ (r.profilesHome + /client.nix) ];

  programs = {
    man.enable = false;
    nix-index.enable = lib.mkForce false;
    zsh.initContent = ''
      LOCALCOLOR=$'%{\e[1;32m%}'
    '';
  };
}
