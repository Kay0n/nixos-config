{
  image = "crocodilestick/calibre-web-automated:latest";
  environment = {
    "PUID" = "1000";
    "PGID" = "1000";
    "TZ" = "Australia/Adelaide";
  };
  volumes = [
    "/home/kayon/book-automation/cwa/config:/config"
    "/home/kayon/book-automation/cwa/ingest:/cwa-book-ingest"
    "/home/kayon/book-automation/cwa/library:/calibre-library"
  ];
  ports = [ 
    "127.0.0.1:8083:8083"
  ];
}

