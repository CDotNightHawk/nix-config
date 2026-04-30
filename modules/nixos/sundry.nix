# Inspired by https://codeberg.org/ihaveahax/nix-config
{
  config,
  lib,
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
  # whether you should `boot` first (e.g. dbus/systemd churn). We use
  # `nix store diff-closures` instead of nvd because nvd shells out to
  # `nix-build --version` to detect the nix version and that binary
  # isn't on PATH inside system activation scripts (lix exposes its
  # CLI through the `nix` multi-call binary; the legacy `nix-build`
  # symlink lives in a different output and we don't pull it in here).
  system.activationScripts.diff = {
    supportsDryActivation = true;
    text = ''
      if [ -e /run/current-system ]; then
        echo "--- closure diff: /run/current-system → $systemConfig ---"
        ${config.nix.package}/bin/nix \
          --extra-experimental-features 'nix-command' \
          store diff-closures /run/current-system "$systemConfig" || true
      fi
    '';
  };
}
