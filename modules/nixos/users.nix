{
  pkgs,
  me,
  ...
}:

{
  users.users.${me} = {
    description = me;
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    linger = true;
    uid = 1000;
  };

  users.users.root.shell = pkgs.zsh;
}
