# Incus high availability

The server profile runs `incus-lts` with AppArmor, nftables, VM support, and a
three-voter cluster policy. Incus remains uninitialized until the cluster
addresses, storage, and member identities are known.

## Availability model

A production cluster should have at least three members. Three voting Cowsql
members allow the control plane to retain quorum when one member is lost. Add
standby members when the cluster grows beyond three nodes.

Workload recovery is a separate concern:

- local ZFS, LVM, or Btrfs supports planned migration while the source is
  online, but cannot recover an instance from an unreachable node;
- Ceph, LINSTOR, LVM Cluster, or another supported remote backend makes
  instance data available to surviving nodes;
- automatic healing also requires reliable fencing through a BMC, managed PDU,
  or equivalent mechanism to prevent both sides of a network partition from
  running the same workload.

The module keeps automatic healing and rebalancing disabled until their
infrastructure is ready. This does not disable database quorum, manual
evacuation, or cluster-wide management.

References:

- [Incus clustering](https://linuxcontainers.org/incus/docs/main/explanation/clustering/)
- [Cluster formation](https://linuxcontainers.org/incus/docs/main/howto/cluster_form/)
- [Cluster healing and maintenance](https://linuxcontainers.org/incus/docs/main/howto/cluster_manage/)
- [Incus storage drivers](https://linuxcontainers.org/incus/docs/main/explanation/storage/)

## Node requirements

Each member needs:

- a unique host name;
- a static address on a reliable management network;
- synchronized time and working forward/reverse DNS;
- the same flake revision and Incus package version;
- compatible CPU features for VM live migration;
- enough spare capacity to absorb an evacuated member.

Create one host directory and flake configuration per physical server. Keep the
shared server profile unchanged and put addresses, interfaces, failure domains,
and hardware settings in the host directories.

Allow port 8443 only on the cluster management interface or exact management
CIDRs:

```nix
nighthawk.incus.cluster = {
  managementInterfaces = [ "bond0.10" ];
  allowedIPv4Ranges = [ "10.10.10.0/24" ];
  allowedIPv6Ranges = [ "fd00:10:10::/64" ];
};
```

The managed instance bridge defaults to `incusbr0`. DNS and DHCP are allowed on
that interface without trusting all traffic from guests.

## Form the cluster

Deploy the NixOS configuration to every empty member before initializing Incus.
Cluster join tokens are single-use secrets and must not be committed to Nix or
stored in the Nix store.

On the first member:

```console
doas incus admin init
```

Enable clustering, use the member's static management address, and configure
the intended storage and network. On the first member, create a token for each
additional node:

```console
incus cluster add server-b
incus cluster add server-c
```

On each new member, run the initializer and paste its token when prompted:

```console
doas incus admin init
```

Joining a cluster destroys existing local Incus data on the joining member.
Verify the completed control plane and apply the declarative HA policy:

```console
incus cluster list
incus-ha-apply
```

The `incus-ha-settings` service applies the same policy on later boots. It exits
successfully without changing anything until the machine belongs to a cluster.

## Shared storage and healing

For three servers with dedicated storage devices, Ceph RBD is the conventional
distributed option. It has meaningful memory, network, and operational cost.
LINSTOR can be a leaner block-storage alternative, while an existing TrueNAS or
SAN can provide remote storage without running a storage quorum on the compute
nodes. Select the backend based on failure domains and recovery requirements,
not only benchmark throughput.

After every workload uses shared storage and external fencing has been tested,
automatic healing can be enabled explicitly:

```nix
nighthawk.incus.cluster.healing = {
  enable = true;
  threshold = 120;
  sharedStorageConfirmed = true;
  fencingConfirmed = true;
};
```

The confirmations are evaluation guards. They do not install or operate the
BMC/PDU fencing system.

Optional VM rebalancing moves at most one VM per run by default:

```nix
nighthawk.incus.cluster.rebalance = {
  enable = true;
  interval = 60;
  threshold = 30;
};
```

## Maintenance and upgrades

Evacuate a member before a reboot or hardware operation:

```console
incus-maintenance evacuate
doas nixos-rebuild switch --flake .#server-a
doas reboot
incus-maintenance restore
```

An explicit member name can be supplied as the second argument. The `status`
action displays cluster membership:

```console
incus-maintenance status
incus-maintenance evacuate server-b
incus-maintenance restore server-b
```

Upgrade one member at a time and do not upgrade while a member is offline.
Incus can temporarily block upgraded members until every member runs the same
version, while existing instances continue running.

## Client access

The client Home Manager profile includes the Incus CLI in its container tooling
bundle. Add a cluster remote with a short-lived trust token:

```console
incus config trust add laptop
incus remote add homelab <token>
```

Use DNS round-robin for a minimal API endpoint, or a TCP load balancer with
health checks for faster failure detection. TLS client authentication requires
TCP pass-through; a load balancer that terminates TLS requires OIDC.

The Incus web interface remains disabled by default. Remote access still uses
certificate or OIDC authentication even when the firewall permits the API
port.
