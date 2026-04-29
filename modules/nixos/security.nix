# doas as our only privilege-escalation tool. We skip sudo entirely to
# keep one mental model. Per-command rules below let `nighthawk` run
# the ergonomic-but-low-blast-radius admin commands without retyping a
# password every five minutes.
#
# Threat model: this is a single-user laptop. Anything that can already
# read disk or modify /nix/store can already root the machine, so
# requiring a password for `nixos-rebuild` adds no real security — it
# just adds friction. We keep persistAuth=true on the few commands that
# DO mutate state so doas remembers your password for ~5 min, the
# rest are noPass.
{
  config,
  lib,
  pkgs,
  me,
  r,
  ...
}:
{
  # Enable U2F Authentication
  security.pam.u2f.enable = true;
  environment.systemPackages = [ pkgs.pam_u2f ];

  security.sudo.enable = false;

  security.doas = {
    enable = true;
    extraRules = [
      {
        users = [ me ];
        # Mutating but not destructive. Cache the password for 5min
        # (default persistAuth window) so a chain of `nh os switch`
        # / `nh home switch` / `nixos-rebuild test` only prompts once.
        persist = true;
        keepEnv = true;
        cmd = "nixos-rebuild";
      }
      {
        users = [ me ];
        persist = true;
        keepEnv = true;
        cmd = "nh";
      }

      # Read-only diagnostics — passwordless. These can't break a
      # running system; making them prompt for a password is pure
      # friction.
      {
        users = [ me ];
        noPass = true;
        cmd = "${pkgs.systemd}/bin/journalctl";
      }
      {
        users = [ me ];
        noPass = true;
        cmd = "${pkgs.systemd}/bin/systemctl";
        args = [ "status" ];
      }
      {
        users = [ me ];
        noPass = true;
        cmd = "${pkgs.systemd}/bin/systemctl";
        args = [ "reload" ];
      }
      {
        users = [ me ];
        noPass = true;
        cmd = "${pkgs.systemd}/bin/systemctl";
        args = [ "list-units" ];
      }

      # nix-* maintenance. nix-collect-garbage and nix-store --optimise
      # only delete unreferenced store paths and dedup files; they
      # cannot brick the system.
      {
        users = [ me ];
        noPass = true;
        cmd = "${config.nix.package}/bin/nix-collect-garbage";
      }
      {
        users = [ me ];
        noPass = true;
        cmd = "${config.nix.package}/bin/nix-store";
        args = [ "--optimise" ];
      }
    ];
  };
}
