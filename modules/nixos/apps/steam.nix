{
  config,
  pkgs,
  ...
}:

{
  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = false;
      gamescopeSession.enable = true;
      extraCompatPackages = [ pkgs.proton-ge-bin ];
    };
    gamemode = {
      enable = true;
      enableRenice = true;
    };
    gamescope = {
      enable = true;
      capSysNice = true;
    };
  };

  environment.systemPackages = with pkgs; [
    mangohud
    protontricks
    vkbasalt
    wineWow64Packages.staging
    winetricks
  ];

  assertions = [
    {
      assertion = config.hardware.graphics.enable32Bit;
      message = "Steam requires hardware.graphics.enable32Bit = true.";
    }
  ];
}
