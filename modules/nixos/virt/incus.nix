{
  config,
  lib,
  pkgs,
  me,
  ...
}:

let
  cfg = config.nighthawk.incus;
  clusterCfg = cfg.cluster;

  healingThreshold = if clusterCfg.healing.enable then clusterCfg.healing.threshold else 0;
  rebalanceInterval = if clusterCfg.rebalance.enable then clusterCfg.rebalance.interval else 0;

  incusHaApply = pkgs.writeShellApplication {
    name = "incus-ha-apply";
    runtimeInputs = [ config.virtualisation.incus.clientPackage ];
    text = ''
      if ! incus cluster list --format csv >/dev/null 2>&1; then
        if [[ "''${1:-}" == "--skip-unclustered" ]]; then
          echo "Incus is not clustered; HA settings were not applied."
          exit 0
        fi

        echo "Incus is not part of a cluster." >&2
        exit 1
      fi

      incus config set "cluster.max_voters=${toString clusterCfg.maxVoters}"
      incus config set "cluster.max_standby=${toString clusterCfg.maxStandby}"
      incus config set "cluster.images_minimal_replica=${toString clusterCfg.imageReplicas}"
      incus config set "cluster.join_token_expiry=${clusterCfg.joinTokenExpiry}"
      incus config set "cluster.offline_threshold=${toString clusterCfg.offlineThreshold}"
      incus config set "cluster.healing_threshold=${toString healingThreshold}"
      incus config set "cluster.rebalance.interval=${toString rebalanceInterval}"
      incus config set "cluster.rebalance.batch=${toString clusterCfg.rebalance.batch}"
      incus config set "cluster.rebalance.cooldown=${clusterCfg.rebalance.cooldown}"
      incus config set "cluster.rebalance.threshold=${toString clusterCfg.rebalance.threshold}"
    '';
  };

  incusMaintenance = pkgs.writeShellApplication {
    name = "incus-maintenance";
    runtimeInputs = [
      config.virtualisation.incus.clientPackage
      pkgs.inetutils
    ];
    text = ''
      action="''${1:-status}"
      member="''${2:-$(hostname --short)}"

      case "$action" in
        evacuate|enter)
          exec incus cluster evacuate "$member"
          ;;
        restore|exit)
          exec incus cluster restore "$member"
          ;;
        status)
          exec incus cluster list
          ;;
        *)
          echo "usage: incus-maintenance {status|evacuate|restore} [member]" >&2
          exit 2
          ;;
      esac
    '';
  };

  ipv4FirewallRule = lib.optionalString (clusterCfg.allowedIPv4Ranges != [ ]) ''
    ip saddr { ${lib.concatStringsSep ", " clusterCfg.allowedIPv4Ranges} } tcp dport ${toString clusterCfg.port} accept comment "Incus cluster API"
  '';
  ipv6FirewallRule = lib.optionalString (clusterCfg.allowedIPv6Ranges != [ ]) ''
    ip6 saddr { ${lib.concatStringsSep ", " clusterCfg.allowedIPv6Ranges} } tcp dport ${toString clusterCfg.port} accept comment "Incus cluster API"
  '';
in
{
  options.nighthawk.incus = {
    enable = lib.mkEnableOption "Incus containers and virtual machines";

    adminUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ me ];
      description = "Users granted full access through the incus-admin group.";
    };

    bridgeName = lib.mkOption {
      type = lib.types.str;
      default = "incusbr0";
      description = "Managed bridge that provides DNS and DHCP to instances.";
    };

    ui.enable = lib.mkEnableOption "the Incus web interface";

    cluster = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Install and enforce the shared Incus HA policy after clustering.";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 8443;
        description = "TCP port used by the Incus API and cluster traffic.";
      };

      managementInterfaces = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [ "bond0.10" ];
        description = "Interfaces allowed to reach the Incus cluster API.";
      };

      allowedIPv4Ranges = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [ "10.10.10.0/24" ];
        description = "IPv4 CIDRs allowed to reach the Incus cluster API.";
      };

      allowedIPv6Ranges = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [ "fd00:10:10::/64" ];
        description = "IPv6 CIDRs allowed to reach the Incus cluster API.";
      };

      maxVoters = lib.mkOption {
        type = lib.types.ints.positive;
        default = 3;
        description = "Maximum number of voting Cowsql database members.";
      };

      maxStandby = lib.mkOption {
        type = lib.types.ints.unsigned;
        default = 2;
        description = "Maximum number of standby Cowsql database members.";
      };

      imageReplicas = lib.mkOption {
        type = lib.types.int;
        default = 3;
        description = "Minimum image replicas; -1 replicates images to every member.";
      };

      joinTokenExpiry = lib.mkOption {
        type = lib.types.str;
        default = "1H";
        description = "Lifetime of single-use cluster join tokens.";
      };

      offlineThreshold = lib.mkOption {
        type = lib.types.ints.positive;
        default = 20;
        description = "Seconds before an unreachable member is considered offline.";
      };

      healing = {
        enable = lib.mkEnableOption "automatic evacuation of failed cluster members";

        threshold = lib.mkOption {
          type = lib.types.ints.positive;
          default = 120;
          description = "Seconds an offline member remains unavailable before evacuation.";
        };

        sharedStorageConfirmed = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Confirm that all automatically healed instances use shared storage.";
        };

        fencingConfirmed = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Confirm that failed members are fenced through a BMC, PDU, or equivalent.";
        };
      };

      rebalance = {
        enable = lib.mkEnableOption "automatic VM load rebalancing";

        interval = lib.mkOption {
          type = lib.types.ints.positive;
          default = 60;
          description = "Minutes between load-rebalancing checks.";
        };

        batch = lib.mkOption {
          type = lib.types.ints.positive;
          default = 1;
          description = "Maximum instances migrated during one rebalancing run.";
        };

        cooldown = lib.mkOption {
          type = lib.types.str;
          default = "6H";
          description = "Minimum time before an instance can be rebalanced again.";
        };

        threshold = lib.mkOption {
          type = lib.types.ints.positive;
          default = 30;
          description = "Load difference percentage required before rebalancing.";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        assertions = [
          {
            assertion = clusterCfg.maxVoters >= 3 && clusterCfg.maxVoters != 2 * (clusterCfg.maxVoters / 2);
            message = "nighthawk.incus.cluster.maxVoters must be an odd number of at least three.";
          }
          {
            assertion = clusterCfg.maxStandby <= 5;
            message = "nighthawk.incus.cluster.maxStandby cannot exceed five.";
          }
          {
            assertion = clusterCfg.imageReplicas == -1 || clusterCfg.imageReplicas >= 1;
            message = "nighthawk.incus.cluster.imageReplicas must be -1 or at least one.";
          }
          {
            assertion = clusterCfg.offlineThreshold >= 10;
            message = "nighthawk.incus.cluster.offlineThreshold must be at least ten seconds.";
          }
          {
            assertion = !clusterCfg.healing.enable || clusterCfg.healing.sharedStorageConfirmed;
            message = "Incus automatic healing requires sharedStorageConfirmed = true.";
          }
          {
            assertion = !clusterCfg.healing.enable || clusterCfg.healing.fencingConfirmed;
            message = "Incus automatic healing requires fencingConfirmed = true.";
          }
          {
            assertion =
              !clusterCfg.healing.enable || clusterCfg.healing.threshold >= clusterCfg.offlineThreshold;
            message = "The Incus healing threshold cannot be lower than the offline threshold.";
          }
          {
            assertion = clusterCfg.rebalance.threshold <= 100;
            message = "The Incus rebalance threshold cannot exceed 100 percent.";
          }
        ];

        virtualisation.incus = {
          enable = true;
          package = pkgs.incus-lts;
          socketActivation = false;
          softDaemonRestart = true;
          ui.enable = cfg.ui.enable;
        };

        security.apparmor.enable = true;

        networking = {
          nftables = {
            enable = true;
            flushRuleset = false;
          };
          firewall.interfaces.${cfg.bridgeName} = {
            allowedTCPPorts = [
              53
              67
            ];
            allowedUDPPorts = [
              53
              67
            ];
          };
        };

        users.users = lib.genAttrs cfg.adminUsers (_: {
          extraGroups = [ "incus-admin" ];
        });

        environment.systemPackages = [ incusMaintenance ];
      }

      (lib.mkIf clusterCfg.enable {
        networking.firewall = {
          extraInputRules = ipv4FirewallRule + ipv6FirewallRule;
          interfaces = lib.genAttrs clusterCfg.managementInterfaces (_: {
            allowedTCPPorts = [ clusterCfg.port ];
          });
        };

        environment.systemPackages = [ incusHaApply ];

        systemd.services.incus-ha-settings = {
          description = "Apply Incus cluster availability policy";
          after = [
            "incus.service"
            "incus-preseed.service"
          ];
          wants = [ "incus.service" ];
          wantedBy = [ "multi-user.target" ];
          restartTriggers = [ incusHaApply ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${incusHaApply}/bin/incus-ha-apply --skip-unclustered";
          };
        };
      })
    ]
  );
}
