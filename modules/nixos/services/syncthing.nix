{
  config,
  me,
  ...
}:

{
  services.syncthing = {
    enable = true;
    user = me;
    dataDir = config.users.users.${me}.home;
    openDefaultPorts = true;
  };

  users.users.${me}.extraGroups = [ "syncthing" ];
}
