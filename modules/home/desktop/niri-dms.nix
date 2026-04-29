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

let
  powerMenu = pkgs.writeShellScriptBin "power-menu" ''
    choice=$(echo -e "suspend\nreboot\npoweroff\nlogout\nlock" | ${pkgs.fuzzel}/bin/fuzzel --dmenu -p "Power: ")
    case "$choice" in
      suspend) systemctl suspend ;;
      reboot) systemctl reboot ;;
      poweroff) systemctl poweroff ;;
      logout) niri msg action quit ;;
      lock) swaylock -f ;;
    esac
  '';
in
{
  imports = [
    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri
    inputs.dsearch.homeModules.dsearch
  ];

  # dsearch (a.k.a. danksearch) — bleve-backed file index used by DMS'
  # launcher for the "search files" panel. The home module provides the
  # dsearch.service systemd unit; turning it on makes DMS' System Check
  # stop flagging "danksearch: Not installed".
  programs.dsearch = {
    enable = true;
  };

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

    #extraConfig = ''
    #  include "~/.config/niri/dms/cursor.kdl"
    #  include "~/.config/niri/dms/outputs.kdl"
    #  include "~/.config/niri/dms/windowrules.kdl"
    #'';

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

    # Session-wide env vars. DISPLAY=:0 tells X11 clients where the
    # xwayland-satellite socket lives; xwayland-satellite is
    # launched on :0 in spawn-at-startup below.
    environment = {
      DISPLAY = ":0";
    };

    # Spawn a clipboard manager + idle handler + XWayland bridge at
    # session start.
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
      # XWayland bridge — needed for Steam, JetBrains IDEs, Zoom, and
      # any other X11-only app. xwayland-satellite creates
      # /tmp/.X11-unix/X0 on demand and proxies it to the running
      # niri compositor. The explicit ":0" matches the DISPLAY env
      # var above; if that ever conflicts with a real X server on
      # the box (it won't on a Wayland-only niri session) bump both
      # to ":2" in lockstep.
      {
        command = [
          "xwayland-satellite"
          ":0"
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

      # --- Admin / system keybinds -----------------------------------
      # All of these run inside a kitty terminal so you can read the
      # output. doas is configured (modules/nixos/security.nix) to
      # remember your password for ~5min and to skip prompts entirely
      # for read-only commands like `journalctl`.

      # Mod+Shift+R: rebuild the system from the current flake checkout.
      # Uses `boot` not `switch` so a bad build doesn't kick you out of
      # the live session — reboot to land on the new generation.
      "Mod+Shift+R".action =
        spawn "kitty" "--hold" "--" "sh" "-c"
          "cd ~/nix-config && doas nixos-rebuild boot --flake \".#$(hostname)\"";

      # Mod+Shift+U: bump flake inputs *and* rebuild. Counterpart to
      # the weekly auto-upgrade timer for when you want a fresh
      # nixpkgs right now.
      "Mod+Shift+U".action =
        spawn "kitty" "--hold" "--" "sh" "-c"
          "cd ~/nix-config && nix flake update && doas nixos-rebuild boot --flake \".#$(hostname)\"";

      # Mod+Shift+L: lock screen (swayidle also auto-locks after 5 min).
      "Mod+Shift+L".action = spawn "swaylock" "-f";

      # Mod+Shift+G: garbage-collect old generations >14 days. Fire and
      # forget; doas is passwordless for this command (see security.nix).
      "Mod+Shift+G".action =
        spawn "kitty" "--hold" "--" "sh" "-c"
          "doas nix-collect-garbage --delete-older-than 14d && doas nix-store --optimise";

      # Mod+Shift+P: power menu via fuzzel. Pick suspend/reboot/poweroff/
      # logout/lock from a dmenu-style picker.
      "Mod+Shift+P".action = spawn "${powerMenu}/bin/power-menu";

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
