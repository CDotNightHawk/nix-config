{ r, ... }:

{
  imports = with r; [
    (modulesHome + /core.nix)
    (modulesHome + /desktop/apps.nix)
    (modulesHome + /desktop/chat.nix)
    (modulesHome + /desktop/niri-dms.nix)
    (modulesHome + /desktop/spicetify.nix)
    (modulesHome + /editors/nixvim.nix)
    (modulesHome + /linux.nix)
    (modulesHome + /sops.nix)
    (modulesHome + /tooling/development.nix)
  ];

  nighthawk = {
    desktopApps.enable = true;
    development = {
      enable = true;
      containers.enable = true;
    };
  };
}
