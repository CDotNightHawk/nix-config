# Home-manager side of niri + DankMaterialShell.
#
# The niri NixOS module already imports `inputs.niri.homeModules.config`
# for every user that has home-manager wired up, so we don't need to
# re-import it here — but we do still need `inputs.dms.homeModules.niri`
# for the niri↔DMS keybind glue.
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri
  ];

  programs.dank-material-shell = {
    enable = true;
    enableSystemMonitoring = true;
    dgop.package = inputs.dgop.packages.${pkgs.system}.default;

    # Run DMS as a systemd user unit bound to graphical-session.target.
    # This gets DMS' own System Check ("dms.service: enabled-runtime,
    # inactive") to go green, gives us proper restart semantics
    # (Restart=on-failure), and means killing/restarting dms doesn't
    # require dropping the whole niri session.
    systemd.enable = true;

    niri = {
      enableKeybinds = true;
      # We *don't* want enableSpawn here. enableSpawn injects
      #   spawn-at-startup "dms" "run"
      # into niri's KDL, which races with systemd starting dms.service:
      # niri launches dms manually, the systemd unit stays in
      # "enabled-runtime, inactive" forever, and DMS' System Check
      # complains. Letting graphical-session.target pull dms.service in
      # is the supported path.
      enableSpawn = false;
      # By default DMS rewrites ~/.config/niri/config.kdl to
      # `include "dms/{alttab,binds,colors,layout,outputs,wpblur}.kdl"`,
      # but those `dms/*.kdl` files are only written at runtime by the
      # DMS QuickShell process. On first boot niri reads the config
      # before DMS has had a chance to start, the includes resolve to
      # nothing, and niri's KDL parser hard-fails with
      #   "failed to read included config from .../dms/alttab.kdl"
      # (see DankMaterialShell distro/nix/niri.nix; the upstream module
      # itself notes that combining enableKeybinds + includes.enable is
      # not recommended, and is waiting on niri-flake#1548).
      #
      # `enableKeybinds` already pulls every DMS keybind into the
      # niri-flake-generated config, so we don't need the runtime
      # includes — turn them off.
      includes.enable = false;
    };
  };

  # niri config — Nix-typed via niri-flake. KDL is generated.
  programs.niri.settings = {
    input.keyboard.xkb = {
      layout = "us";
    };

    input.touchpad = {
      tap = true;
      natural-scroll = true;
      dwt = true; # disable while typing
      click-method = "clickfinger";
    };

    # Slightly smaller default gaps + sensible focus ring.
    layout = {
      gaps = 8;
      border = {
        enable = true;
        width = 2;
      };
      focus-ring = {
        enable = true;
        width = 2;
      };
    };

    # Workspaces: 1..9 + a "scratch" overflow.
    workspaces = {
      "01-main" = { };
      "02-web" = { };
      "03-chat" = { };
      "04-media" = { };
    };

    # Keep DMS as the visual shell — niri's own status bar stays off.
    # (DMS' niri integration handles bar + launcher + locks.)
    prefer-no-csd = true;
    hotkey-overlay.skip-at-startup = true;

    # Spawn a clipboard manager + idle handler at session start.
    spawn-at-startup = [
      {
        command = [
          "wl-paste"
          "--watch"
          "cliphist"
          "store"
        ];
      }
      {
        command = [
          "swayidle"
          "-w"
          "timeout"
          "300"
          "swaylock -f"
          "timeout"
          "600"
          "niri msg action power-off-monitors"
          "before-sleep"
          "swaylock -f"
        ];
      }
    ];

    # A few QoL keybinds beyond the DMS preset (which already covers
    # launcher, app drawer, notifications, settings).
    binds = with config.lib.niri.actions; {
      "Mod+Return".action = spawn "kitty";
      "Mod+Q".action = close-window;
      "Mod+F".action = maximize-column;
      "Mod+Shift+F".action = fullscreen-window;
      "Mod+T".action = toggle-window-floating;

      # (DMS preset already binds Mod+V to its clipboard manager; if
      # you'd rather use cliphist+fuzzel, drop `enableKeybinds = true`
      # above and bind it explicitly here.)

      # Screenshots: niri's built-in actions are dispatched via niri-msg
      # so we don't have to thread parameter records through the
      # niri-flake DSL. Adjust as needed.
      "Print".action = spawn "niri" "msg" "action" "screenshot";
      "Mod+Print".action = spawn "niri" "msg" "action" "screenshot-screen";
      "Mod+Shift+Print".action = spawn "niri" "msg" "action" "screenshot-window";

      # Note: DMS' preset niri keybinds already cover the XF86
      # brightness / audio / media keys via its own osd. Adding our
      # own bindings here would clash with the DMS preset and refuse
      # to evaluate, so we leave them to DMS.
    };
  };

  home.packages = with pkgs; [
    kitty
    fuzzel
  ];
}
