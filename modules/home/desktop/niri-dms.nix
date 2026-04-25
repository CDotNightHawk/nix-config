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
    niri = {
      enableKeybinds = true;
      enableSpawn = true;
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
