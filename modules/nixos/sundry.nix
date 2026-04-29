# Inspired by https://codeberg.org/ihaveahax/nix-config
{
  config,
  lib,
  pkgs,
  me,
  ...
}:

{
  # due to networkmanager-openconnect causing webkitgtk to build with an extreme build time
  networking.networkmanager.plugins = lib.mkForce [ ];

  # `system.rebuild.enableNg` was removed; nixos-rebuild-ng is the
  # default now.

  environment.variables.MANPAGER = "nvim +Man!";

  # Print a closure diff after every nixos-rebuild switch. Lets you
  # see at a glance which packages got added/removed/upgraded — handy
  # when you want to know whether a rebuild is safe to `switch` or
  # whether you should `boot` first (e.g. dbus/systemd churn). Output
  # is piped through nvd if available, otherwise nix store diff-closures.
  system.activationScripts.diff = {
    supportsDryActivation = true;
    text = ''
      if [ -e /run/current-system ]; then
        echo "--- closure diff: /run/current-system → $systemConfig ---"
        ${pkgs.nvd}/bin/nvd --color always diff /run/current-system "$systemConfig" || true
      fi
    '';
  };
}
