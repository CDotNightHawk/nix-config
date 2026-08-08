{
  config,
  me,
  ...
}:

{
  systemd = {
    services.clean-up-home-manager = {
      path = [ config.nix.package ];
      script = ''
        for f in ${config.users.users.${me}.home}/.local/state/nix/profiles/home-manager /nix/var/nix/profiles/per-user/root/home-manager; do
          if [ -e "$f" ]; then
            nix-env --profile "$f" --delete-generations old
          fi
        done
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
    };

    timers.clean-up-home-manager = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "weekly";
        Persistent = true;
        RandomizedDelaySec = "45min";
        Unit = "clean-up-home-manager.service";
      };
    };
  };
}
