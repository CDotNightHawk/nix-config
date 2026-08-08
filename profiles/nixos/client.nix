{
  inputs,
  r,
  ...
}:

{
  imports = with r; [
    ./base.nix
    (modulesNixos + /apps/flatpak.nix)
    (modulesNixos + /apps/steam.nix)
    (modulesNixos + /desktop/dms.nix)
    (modulesNixos + /desktop/firefox.nix)
    (modulesNixos + /desktop/keyring.nix)
    (modulesNixos + /desktop/ly.nix)
    (modulesNixos + /desktop/niri.nix)
    (modulesNixos + /desktop/sound.nix)
    (modulesNixos + /home-manager.nix)
    (modulesNixos + /polkit-rules.nix)
    (modulesNixos + /virt/podman.nix)
    inputs.night-nur.nixosModules.overlay
    inputs.nix-flatpak.nixosModules.nix-flatpak
  ];

  nightpkg.packages.enableExtra = true;
  nighthawk.autoUpgrade.enable = true;
}
