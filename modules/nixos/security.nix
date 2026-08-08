{
  config,
  lib,
  pkgs,
  me,
  ...
}:

let
  cfg = config.nighthawk.security;
in
{
  options.nighthawk.security = {
    hardening.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable low-overhead kernel and network hardening.";
    };
    u2f.enable = lib.mkEnableOption "PAM U2F authentication";
  };

  config = lib.mkMerge [
    {
      security.sudo.enable = false;
      security.doas = {
        enable = true;
        extraRules = [
          {
            users = [ me ];
            persist = true;
          }
        ];
      };
    }

    (lib.mkIf cfg.u2f.enable {
      security.pam.u2f.enable = true;
      environment.systemPackages = [ pkgs.pam_u2f ];
    })

    (lib.mkIf cfg.hardening.enable {
      security.protectKernelImage = true;

      boot.kernel.sysctl = {
        "fs.protected_fifos" = 2;
        "fs.protected_hardlinks" = 1;
        "fs.protected_regular" = 2;
        "fs.protected_symlinks" = 1;
        "kernel.dmesg_restrict" = 1;
        "kernel.kptr_restrict" = 2;
        "kernel.perf_event_paranoid" = 3;
        "kernel.unprivileged_bpf_disabled" = 1;
        "kernel.yama.ptrace_scope" = 1;
        "net.ipv4.conf.all.accept_redirects" = 0;
        "net.ipv4.conf.all.accept_source_route" = 0;
        "net.ipv4.conf.all.send_redirects" = 0;
        "net.ipv4.conf.default.accept_redirects" = 0;
        "net.ipv4.conf.default.accept_source_route" = 0;
        "net.ipv4.conf.default.send_redirects" = 0;
        "net.ipv6.conf.all.accept_redirects" = 0;
        "net.ipv6.conf.all.accept_source_route" = 0;
        "net.ipv6.conf.default.accept_redirects" = 0;
        "net.ipv6.conf.default.accept_source_route" = 0;
      };
    })
  ];
}
