{ pkgs, ... }:

{
  services = {
    printing = {
      enable = true;
      drivers = with pkgs; [
        gutenprint
        gutenprintBin
      ];
    };
    system-config-printer.enable = true;
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };

  programs.system-config-printer.enable = true;
  environment.systemPackages = [ pkgs.cups-pk-helper ];
}
