# gnome-keyring as the system-wide Secret Service provider.
#
# Why this exists: on a minimal niri install there's no daemon
# implementing the org.freedesktop.secrets DBus API, so apps that
# need to stash credentials fall back to plain-text / weakly-
# encrypted storage. The VSCode prompt
#
#   "Data will be stored using 'basic text encoding' which is
#    unencrypted. Do you want to continue?"
#
# is exactly this: libsecret couldn't find a Secret Service on the
# bus, so VSCode fell back to writing the GitHub PAT to disk with
# trivial XOR obfuscation. Firefox, Chromium, gh CLI, Git
# credential helper, Discord, Slack, Signal, and every other
# libsecret consumer hit the same fallback.
#
# Fix: run gnome-keyring-daemon as a user unit. It:
#   - registers as the Secret Service on the session bus, so
#     libsecret stores credentials in ~/.local/share/keyrings/login.keyring
#     (AES-256 under a key derived from the user's login password)
#   - provides a PKCS#11 module for certificate storage
#   - exposes the SSH + GPG agents (we turn those off below so we
#     don't conflict with ssh-agent we already run from
#     modules/nixos/ssh.nix)
#
# The keyring is automatically unlocked when the user logs in,
# via pam_gnome_keyring.so in ly's PAM stack — no second prompt.
# That's what `security.pam.services.ly.enableGnomeKeyring = true`
# below does.
{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Enables the user-session gnome-keyring-daemon + its DBus
  # activation unit. Pulls gnome-keyring + libsecret onto the
  # system.
  services.gnome.gnome-keyring.enable = true;

  # Auto-unlock the keyring on ly login. pam_gnome_keyring.so gets
  # the user's password from the PAM stack and uses it to derive
  # the AES key that decrypts login.keyring. No second prompt, no
  # plain-text fallback.
  #
  # The `ly` PAM service is created by services.displayManager.ly
  # — editing it here layers our option on top.
  security.pam.services.ly.enableGnomeKeyring = true;

  # Seahorse — GUI for browsing / renaming / removing stored
  # keyring entries. Useful when VSCode or gh CLI wedges a stale
  # token and you want to nuke it without touching shell.
  environment.systemPackages = with pkgs; [
    seahorse

    # libsecret comes as a dependency of most consumers, but
    # installing it explicitly means `secret-tool` is on PATH for
    # scripted credential fetches (useful in shell aliases).
    libsecret
  ];

  # NB: gnome-keyring's ssh and gpg components would fight our
  # existing ssh-agent (modules/nixos/ssh.nix) and gpg-agent. The
  # upstream nixpkgs gnome-keyring module already disables the
  # gcr-ssh-agent socket via services.gnome.gcr-ssh-agent.enable,
  # and niri.nix mkForces that off. The gpg agent is still fine
  # to leave alone — gnome-keyring only activates its own gpg
  # subcomponent if GPG_AGENT_INFO isn't set.
}
