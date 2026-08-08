{ pkgs, ... }:

{
  # Disable legacy PulseAudio in favor of PipeWire.
  services.pulseaudio.enable = false;

  # Real-time scheduling for audio threads.
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;
  };

  environment.systemPackages = with pkgs; [
    pavucontrol
    qpwgraph
    easyeffects
  ];
}
