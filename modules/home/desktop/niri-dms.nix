{
  config,
  pkgs,
  inputs,
  ...
}:

let
  powerMenu = pkgs.writeShellScriptBin "power-menu" ''
    choice=$(printf 'suspend\nreboot\npoweroff\nlogout\nlock\n' | ${pkgs.fuzzel}/bin/fuzzel --dmenu -p "Power: ")
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

  programs = {
    dsearch.enable = true;
    dank-material-shell = {
      enable = true;
      enableSystemMonitoring = true;
      dgop.package = inputs.dgop.packages.${pkgs.stdenv.hostPlatform.system}.default;
      systemd.enable = true;
      niri = {
        enableKeybinds = true;
        enableSpawn = false;
        # Runtime-generated includes are unavailable during niri's first start.
        includes.enable = false;
      };
    };

    niri.settings = {
      input = {
        keyboard.xkb.layout = "us";
        touchpad = {
          tap = true;
          natural-scroll = true;
          dwt = true;
          click-method = "clickfinger";
        };
      };

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

      workspaces = {
        "01-main" = { };
        "02-web" = { };
        "03-chat" = { };
        "04-media" = { };
      };

      prefer-no-csd = true;
      hotkey-overlay.skip-at-startup = true;
      environment.DISPLAY = ":0";

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
        {
          command = [
            "xwayland-satellite"
            ":0"
          ];
        }
      ];

      binds = with config.lib.niri.actions; {
        "Mod+Return".action = spawn "kitty";
        "Mod+Q".action = close-window;
        "Mod+F".action = maximize-column;
        "Mod+Shift+F".action = fullscreen-window;
        "Mod+T".action = toggle-window-floating;

        "Print".action = spawn "niri" "msg" "action" "screenshot";
        "Mod+Print".action = spawn "niri" "msg" "action" "screenshot-screen";
        "Mod+Shift+Print".action = spawn "niri" "msg" "action" "screenshot-window";

        "Mod+Shift+R".action =
          spawn "kitty" "--hold" "--" "sh" "-c"
            "cd ~/nix-config && doas nixos-rebuild boot --flake \".#$(hostname)\"";
        "Mod+Shift+U".action =
          spawn "kitty" "--hold" "--" "sh" "-c"
            "cd ~/nix-config && nix flake update && doas nixos-rebuild boot --flake \".#$(hostname)\"";
        "Mod+Shift+G".action =
          spawn "kitty" "--hold" "--" "sh" "-c"
            "doas nix-collect-garbage --delete-older-than 14d && doas nix-store --optimise";
        "Mod+Shift+L".action = spawn "swaylock" "-f";
        "Mod+Shift+P".action = spawn "${powerMenu}/bin/power-menu";
      };
    };
  };

  home.packages = with pkgs; [
    fuzzel
    kitty
  ];
}
