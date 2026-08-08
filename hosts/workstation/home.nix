{ r, ... }:

{
  imports = [ (r.profilesHome + /client.nix) ];

  programs.zsh.initContent = ''
    LOCALCOLOR=$'%{\e[1;36m%}'
  '';
}
