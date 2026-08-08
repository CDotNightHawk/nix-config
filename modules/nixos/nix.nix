_:

{
  nixpkgs.overlays = [
    (final: prev: {
      mdbook-linkcheck = final.mdbook-linkcheck2;
      lix = prev.lix.overrideAttrs (_: {
        # Lix's mount-namespace install checks require capabilities that are
        # unavailable on standard GitHub-hosted runners.
        doInstallCheck = false;
      });
    })
  ];
}
