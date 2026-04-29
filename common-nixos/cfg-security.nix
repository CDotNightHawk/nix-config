{
  config,
  pkgs,
  r,
  ...
}:
{
  security.doas.enable = true;
  security.sudo.enable = false;
}
