# Inspired by https://codeberg.org/ihaveahax/nix-config
{
  config,
  lib,
  pkgs,
  me,
  r,
  ...
}:

let
  zshShared = pkgs.callPackage (r.extras + /shared-zsh-settings.nix) { inherit config; };
in
{
  programs.zsh = {
    enable = true;
  };

  environment.variables.ZDOTDIR = "$HOME/.config/zsh";

  # this gets configured in common-home/core.nix
  # maybe i'll move it over some time?
  #environment.systemPackages = with pkgs; [ eza ];

  users.users = {
    #  root.shell = pkgs.zsh;
    ${me}.shell = pkgs.zsh;
  };

  #home-manager.users.${me} = {
  #  xdg.configFile."zsh/.zshrc".text = "# This is to prevent zsh-newuser-install from running.";
  #  programs.zsh.enable = lib.mkForce false;
  #};
}
