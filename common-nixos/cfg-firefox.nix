# Inspired by https://codeberg.org/ihaveahax/nix-config
{
  config,
  lib,
  pkgs,
  r,
  ...
}:

# https://discourse.nixos.org/t/declare-firefox-extensions-and-settings/36265

{
  programs.firefox = {
    enable = true;
    nativeMessagingHosts.packages = with pkgs; [
      # note: plasma6 adds itself here
      keepassxc
    ];
    # preferences are all pushed via policies.Preferences below so we
    # don't end up defining the same key in two places.
    policies = import (r.extras + /firefox-policies.nix);
    #package = pkgs.firefox-esr-128;
  };
}
