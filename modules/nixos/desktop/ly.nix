{ lib, ... }:

{
  services.displayManager.ly = {
    enable = true;
    settings = {
      # tty1 remains available for recovery logins.
      tty = lib.mkForce 7;
      animate = true;
      animation = "matrix";
      asterisk = "*";
      bigclock = "en";
      blank_box = true;
      clock = "%c";
      hide_borders = true;
      input_len = 34;
      load = true;
      save = true;
    };
  };
}
