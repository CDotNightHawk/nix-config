# Inspired by https://codeberg.org/ihaveahax/nix-config
{ config, pkgs, ... }:

let
  addKeysToAgent = "yes";
  controlMaster = "auto";
  controlPersist = "30m";
in
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      framework = {
        inherit addKeysToAgent controlMaster controlPersist;
        user = "nighthawk";
        hostname = "thancred.tail08e9a.ts.net";
      };
      workstation = {
        inherit addKeysToAgent controlMaster controlPersist;
        user = "nighthawk";
        hostname = "homeserver.tail08e9a.ts.net";
      };
    };
  };
}
