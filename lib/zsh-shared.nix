{ config, ... }:

{
  shellInit = "";
  loginShellInit = "";

  interactiveShellInit = ''
    if [ "$(id -u)" != 0 ] && [ "$IGNORE_DOTFILE_SECRETS" != 1 ] && [ -r "$HOME/.shellsecrets" ]; then
      source "$HOME/.shellsecrets"
    fi
  '';

  options = [
    "EXTENDED_HISTORY"
    "HIST_EXPIRE_DUPS_FIRST"
    "APPEND_HISTORY"
  ];

  ohMyZsh = {
    plugins = [
      "git"
      "docker"
      "docker-compose"
      "python"
    ]
    ++ (if config.programs.tmux.enable then [ "tmux" ] else [ ]);
    config = ''
      zstyle ':omz:update' mode disabled
    '';
  };
}
