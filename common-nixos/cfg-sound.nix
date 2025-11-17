# Inspired by https://codeberg.org/ihaveahax/nix-config
{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Enable sound with pipewire.
  services.pulseaudio.enable = false; # Disable legacy PulseAudio
  security.rtkit.enable = true; # Enable real-time audio permissions
  services.pipewire = {
    enable = true;
    alsa.enable = true; # Advanced Linux Sound Architecture (ALSA) provides audio and MIDI functionality
    alsa.support32Bit = true;
    pulse.enable = true; # Enables the pipewire-pulse replacement server

    # JACK support for advanced routing and virtual machines
    jack.enable = true;

    # Using wireplumber instead
    media-session.enable = false;
  };
  services.wireplumber.enable = true;
  home.packages = with pkgs; [
    qpwgraph # A PipeWire Graph Qt GUI Interface
    
    pavucontrol # Default Pipewire GUI
    easyeffects # Plugins for PipeWire applications 
  ];
}
