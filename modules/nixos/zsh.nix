{
  pkgs,
  me,
  ...
}:

{
  programs.zsh.enable = true;
  environment.variables.ZDOTDIR = "$HOME/.config/zsh";
  users.users.${me}.shell = pkgs.zsh;
}
