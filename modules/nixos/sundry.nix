{
  config,
  lib,
  ...
}:

{
  # Avoid the WebKit closure pulled in by NetworkManager OpenConnect.
  networking.networkmanager.plugins = lib.mkForce [ ];

  system.activationScripts.diff = {
    supportsDryActivation = true;
    text = ''
      if [ -e /run/current-system ]; then
        ${config.nix.package}/bin/nix \
          --extra-experimental-features 'nix-command' \
          store diff-closures /run/current-system "$systemConfig" || true
      fi
    '';
  };
}
