# Optional rootful Docker backend. Client profiles use Podman by default.
{ me, ... }:

{
  virtualisation = {
    docker = {
      enable = true;
      storageDriver = "overlay2";
    };
    oci-containers.backend = "docker";
  };

  users.groups.docker.members = [ me ];
}
