# Flatpak + Flathub, declaratively managed via the gmodena/nix-flatpak
# NixOS module.
#
# Why nix-flatpak vs vanilla services.flatpak.enable:
#   - Lets us list Flathub remotes + apps in *Nix*, just like
#     `environment.systemPackages`. That means the set of installed
#     flatpaks survives a wipe-and-reinstall and is reviewable in PRs.
#   - Adds a systemd timer (`flatpak-managed-install.service`) that
#     reconciles the declared list on boot/weekly. Apps you remove
#     from this file get uninstalled automatically.
#   - You can still `flatpak install <app>` ad-hoc from the CLI; the
#     reconciler only manages the apps it knows about (uninstallUnused
#     defaults to false).
#
# Flathub is added at the *system* level so every user on the box
# sees the remote without having to add it themselves.
{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.flatpak = {
    enable = true;

    # Add Flathub as a system remote. The .flatpakrepo file is the
    # canonical way to register a remote — it embeds the GPG signing
    # key + URL so we don't have to hardcode either.
    remotes = [
      {
        name = "flathub";
        location = "https://flathub.org/repo/flathub.flatpakrepo";
      }
      # Flathub's beta channel — uncomment if you want preview builds.
      # {
      #   name = "flathub-beta";
      #   location = "https://flathub.org/beta-repo/flathub-beta.flatpakrepo";
      # }
    ];

    # Declarative app set. Add appIDs here to have them installed on
    # the next switch / weekly reconcile.
    #
    # Empty by default — drop in appIDs as you go (e.g.
    #   { appId = "com.spotify.Client"; origin = "flathub"; }
    # ). Keeping this list small + curated; for one-off apps just use
    # `flatpak install` from a terminal, the reconciler will leave
    # those alone (uninstallUnused = false below).
    packages = [
      # Soundux — soundboard for PipeWire. Upstream is unmaintained
      # and was dropped from nixpkgs (PR #384195), so we go flatpak.
      {
        appId = "io.github.Soundux";
        origin = "flathub";
      }

      # Templates for when you want to add more later:
      # { appId = "com.discordapp.Discord";   origin = "flathub"; }
      # { appId = "com.spotify.Client";       origin = "flathub"; }
      # { appId = "org.signal.Signal";        origin = "flathub"; }
      # { appId = "com.obsproject.Studio";    origin = "flathub"; }
      # { appId = "org.blender.Blender";      origin = "flathub"; }
    ];

    # Do NOT remove flatpaks the user installed manually. Only the
    # entries in `packages` above are managed.
    uninstallUnused = false;

    # Run the reconciler on boot + once a week. `update.onActivation`
    # also pulls newer revisions of declared apps when running
    # nixos-rebuild switch.
    update = {
      auto = {
        enable = true;
        onCalendar = "weekly";
      };
      onActivation = false; # don't block nixos-rebuild on flathub fetches
    };
  };

  # NB: do *not* set environment.sessionVariables.XDG_DATA_DIRS here.
  # NixOS' core shells-environment module computes XDG_DATA_DIRS from
  # `environment.profileRelativeSessionVariables` (default `[ "/share" ]`),
  # which expands to /run/current-system/sw/share + per-profile share
  # dirs — that's where every Nix-installed `.desktop` file lives.
  # Setting `environment.sessionVariables.XDG_DATA_DIRS = [...]` would
  # override that list (sessionVariables wins over profileRelative when
  # the same key is in both), wiping out launcher/icon/MIME discovery
  # for non-flatpak apps.
  #
  # The upstream `services.flatpak` NixOS module already does the
  # right thing: it adds `/var/lib/flatpak/exports` and
  # `$HOME/.local/share/flatpak/exports` to `environment.profiles`,
  # which (via profileRelativeSessionVariables) gets `.../share`
  # appended onto XDG_DATA_DIRS automatically. So flatpak `.desktop`
  # files show up in DMS' launcher / fuzzel without us touching env
  # vars.

  # Flatpaks need xdg-desktop-portal to talk to the host (file picker,
  # screenshot, etc.). The niri module already enables xdg-portal +
  # the gtk + wlr backends — re-asserting here so this module is
  # self-contained and a host that imports just flatpak.nix without
  # niri.nix still gets a working portal.
  xdg.portal = {
    enable = true;
    wlr.enable = lib.mkDefault true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  };
}
