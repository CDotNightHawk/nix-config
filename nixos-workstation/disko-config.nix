# Declarative disk layout for the workstation.
#
# Run on the install media:
#
#   sudo nix --extra-experimental-features "nix-command flakes" run \
#     github:nix-community/disko -- \
#     --mode disko ./nixos-workstation/disko-config.nix
#
# Then `nixos-install --flake .#workstation`.
#
# Single NVMe BTRFS layout: rootfs / home / nix / persist / swap, all
# zstd-compressed. Edit the `device =` line below to match your actual
# disk.
{ ... }:
{
  disko.devices = {
    disk.main = {
      type = "disk";
      # Replace with your real path before running disko! Use
      # `lsblk -o NAME,SERIAL,SIZE,MODEL` and prefer
      # /dev/disk/by-id/... so future kernels don't reorder names.
      device = "/dev/disk/by-id/REPLACE-ME";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            priority = 1;
            name = "ESP";
            start = "1M";
            end = "1024M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          root = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [
                "-L"
                "workstation"
                "-f"
              ];
              subvolumes = {
                "/rootfs" = {
                  mountpoint = "/";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
                "/home" = {
                  mountpoint = "/home";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
                "/nix" = {
                  mountpoint = "/nix";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
                "/persist" = {
                  mountpoint = "/persist";
                  mountOptions = [
                    "compress=zstd"
                    "noatime"
                  ];
                };
                "/swap" = {
                  mountpoint = "/swap";
                  swap.swapfile.size = "16G";
                };
              };
            };
          };
        };
      };
    };
  };
}
