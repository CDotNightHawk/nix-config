# Inspired by https://codeberg.org/ihaveahax/nix-config
let
  lock-false = {
    Value = false;
    Status = "locked";
  };
  lock-true = {
    Value = true;
    Status = "locked";
  };
in
{
  DisableTelemetry = true;
  DisableFirefoxStudies = true;
  DisablePocket = true;
  EnableTrackingProtection = {
    Value = true;
    Cryptomining = true;
    Fingerprinting = true;
    EmailTracking = true;
  };
  DisplayBookmarksToolbar = "newtab";
  DontCheckDefaultBrowser = true;
  SearchBar = "unified";

  ExtensionSettings = {
    "adnauseam@rednoise.org" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/adnauseam/latest.xpi";
      installation_mode = "force_installed";
    };
    "plasma-browser-integration@kde.org" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/plasma-integration/latest.xpi";
      installation_mode = "force_installed";
    };
    "keepassxc-browser@keepassxc.org" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/keepassxc-browser/latest.xpi";
      installation_mode = "force_installed";
    };
    "{bf9e77ee-c405-4dd7-9bed-2f55e448d19a}" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/jetbrains-toolbox/latest.xpi";
      installation_mode = "force_installed";
    };
    "nekocaption@gmail.com" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/nekocap/latest.xpi";
      installation_mode = "force_installed";
    };
    "hello@bitwarden.com" = {
      install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
      installation_mode = "force_installed";
    };
  };

  Preferences = {
    "extensions.pocket.enabled" = lock-false;
    # https://gladtech.social/@cuchaz/112775302929069283
    "dom.private-attribution.submission.enabled" = lock-false;
    "browser.shopping.experience2023.active" = lock-false;
    "browser.shopping.experience2023.survey.enabled" = lock-false;
    "browser.newtabpage.activity-stream.showSponsored" = lock-false;
    "browser.newtabpage.activity-stream.showSponsoredTopSites" = lock-false;
    "browser.newtabpage.activity-stream.system.showSponsored" = lock-false;
    "browser.urlbar.sponsoredTopSites" = lock-false;
    "browser.ml.chat.enabled" = lock-false;
    "browser.ml.chat.shortcuts" = lock-false;
    "browser.ml.chat.shortcuts.custom" = lock-false;
    "browser.ml.chat.sidebar" = lock-false;
    "browser.ml.enable" = lock-false;
    "extensions.ml.enabled" = lock-false;
    "browser.topsites.contile.enabled" = lock-false;
    "browser.tabs.groups.smart.enabled" = lock-false;
    "browser.tabs.groups.smart.optin" = lock-false;
    "browser.tabs.groups.smart.userEnabled" = lock-false;
  };
}

