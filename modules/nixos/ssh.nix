{
  config,
  lib,
  me,
  r,
  ...
}:

let
  cfg = config.nighthawk.ssh;
in
{
  options.nighthawk.ssh = {
    enable = lib.mkEnableOption "the hardened OpenSSH service";
    port = lib.mkOption {
      type = lib.types.port;
      default = 22;
      description = "TCP port for OpenSSH.";
    };
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Open the configured SSH port in the firewall.";
    };
    allowTcpForwarding = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Allow SSH TCP forwarding and tunnels.";
    };
    authorizedKeyFiles = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [ (r.libs + /keys/id_rsa.pub) ];
      description = "Public-key files authorized for the primary user.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.${me}.openssh.authorizedKeys.keyFiles = cfg.authorizedKeyFiles;

    services.openssh = {
      enable = true;
      ports = [ cfg.port ];
      inherit (cfg) openFirewall;
      settings = {
        AllowAgentForwarding = false;
        AllowTcpForwarding = if cfg.allowTcpForwarding then "yes" else "no";
        GatewayPorts = "no";
        KbdInteractiveAuthentication = false;
        LogLevel = "VERBOSE";
        LoginGraceTime = 30;
        MaxAuthTries = 3;
        MaxSessions = 5;
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        PermitTunnel = false;
        X11Forwarding = false;
      };
    };

    services.fail2ban = {
      enable = true;
      maxretry = 5;
      bantime = "1h";
      bantime-increment = {
        enable = true;
        multipliers = "1 2 4 8 16 32 64";
        maxtime = "168h";
        overalljails = true;
      };
      ignoreIP = [
        "127.0.0.0/8"
        "::1"
      ];
      jails.sshd.settings = {
        enabled = true;
        mode = "aggressive";
        port = toString cfg.port;
      };
    };
  };
}
