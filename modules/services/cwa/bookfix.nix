{
  flake.modules.nixos.cwa = { pkgs, ... }: let
    libraryPath = "/home/kayon/book-automation/cwa/library";
    port = 8091;
  in {
    # Receives text corrections from the KOReader bookfix plugin and applies
    # approved ones to the library EPUBs. Review UI: https://books.refract.online/bookfix/
    # Token (plugin + UI password):  sudo cat /var/lib/bookfix/token
    systemd.services.bookfix = {
      description = "Book fix queue for Calibre-Web-Automated";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      environment = {
        BOOKFIX_LIBRARY = libraryPath;
        BOOKFIX_STATE = "/var/lib/bookfix";
        BOOKFIX_PORT = toString port;
        BOOKFIX_BASE_PATH = "/bookfix";
        BOOKFIX_CONVERT = "${pkgs.calibre}/bin/ebook-convert";
        HOME = "/var/lib/bookfix";
        QT_QPA_PLATFORM = "offscreen";
      };

      serviceConfig = {
        ExecStart = "${pkgs.python3}/bin/python3 ${./bookfix/server.py}";
        User = "kayon";
        Group = "users";
        StateDirectory = "bookfix";
        StateDirectoryMode = "0700";
        Restart = "on-failure";
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ReadWritePaths = [ libraryPath ];
      };
    };

    services.caddy.virtualHosts."books.refract.online".extraConfig = ''
      redir /bookfix /bookfix/
      handle /bookfix/* {
        uri strip_prefix /bookfix
        reverse_proxy 127.0.0.1:${toString port}
      }
    '';
  };
}
