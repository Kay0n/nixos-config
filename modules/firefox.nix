{ config, pkgs, ... }:

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
  programs = {
    firefox = {
      enable = true;
      languagePacks = [ "en-US" ];

      /* ---- POLICIES ---- */
      # see about:policies#documentation for options
      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        PasswordManagerEnabled = false;
        EnableTrackingProtection = {
          Value= true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
        DisablePocket = true;
        # DisableFirefoxAccounts = true;
        # DisableAccounts = true;
        DisableFirefoxScreenshots = true;
        OverrideFirstRunPage = "";
        OverridePostUpdatePage = "";
        DontCheckDefaultBrowser = true;
        DisplayBookmarksToolbar = "always"; # alternatives: "never" or "newtab"
        DisplayMenuBar = "default-off"; # alternatives: "always", "never" or "default-on"
        SearchBar = "unified"; # alternative: "separate"

        /* ---- EXTENSIONS ---- */
        # see about:support for extension/add-on ID strings
        # find addon url for 
        # installation_mode - [ "allowed", "blocked", "force_installed", "normal_installed" ]
        ExtensionSettings = {
          # "*".installation_mode = "blocked"; # blocks all addons except the ones specified
          # uBlock Origin:
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
          };
          # Absolute Enable Right Click & Copy
          "{9350bc42-47fb-4598-ae0f-825e3dd9ceba}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/absolute-enable-right-click/latest.xpi";
            installation_mode = "force_installed";
          };
          # Bitwarden Password Manager
          "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
            installation_mode = "force_installed";
          };
          # Dark Reader
          "addon@darkreader.org" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
            installation_mode = "force_installed";
          };
          # FastForward
          "addon@fastforward.team" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/fastforwardteam/latest.xpi";
            installation_mode = "force_installed";
          };
          # Don't Fuck With Paste
          "DontFuckWithPaste@raim.ist" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/don-t-fuck-with-paste/latest.xpi";
            installation_mode = "force_installed";
          };
          # Sponsorblock
          "sponsorBlocker@ajay.app" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
            installation_mode = "force_installed";
          };
          #WebToEpub
          "WebToEpub@Baka-tsuki.org" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/webtoepub/latest.xpi";
            installation_mode = "force_installed";
          };

        };
  
        /* ---- PREFERENCES ---- */
        # see about:config for options
        Preferences = { 
          "browser.contextual-password-manager.enabled" = lock-false;
          "browser.contentblocking.category" = { Value = "strict"; Status = "locked"; };
          "extensions.pocket.enabled" = lock-false;
          "extensions.screenshots.disabled" = lock-true;
          "browser.topsites.contile.enabled" = lock-false;
          # "browser.formfill.enable" = lock-false;
          # "browser.search.suggest.enabled" = lock-false;
          "browser.search.suggest.enabled.private" = lock-false;
          # "browser.urlbar.suggest.searches" = lock-false;
          # "browser.urlbar.showSearchSuggestionsFirst" = lock-false;
          "browser.newtabpage.activity-stream.feeds.section.topstories" = lock-false;
          "browser.newtabpage.activity-stream.feeds.snippets" = lock-false;
          "browser.newtabpage.activity-stream.section.highlights.includePocket" = lock-false;
          "browser.newtabpage.activity-stream.section.highlights.includeBookmarks" = lock-false;
          "browser.newtabpage.activity-stream.section.highlights.includeDownloads" = lock-false;
          "browser.newtabpage.activity-stream.section.highlights.includeVisited" = lock-false;
          "browser.newtabpage.activity-stream.showSponsored" = lock-false;
          "browser.newtabpage.activity-stream.system.showSponsored" = lock-false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = lock-false;
          "browser.toolbars.bookmarks.visibility" = { Value = "always"; Status = "locked"; };
        };
      };
    };
  };
}