
{ pkgs, ... }:
let
  libraryPath = "/home/kayon/book-automation/cwa/library";
  pagesColumn = "page_count";  

  cwa-pagecount = pkgs.writeShellScriptBin "cwa-pagecount" ''
    set -euo pipefail

    LIBRARY="${libraryPath}"
    PAGES_COLUMN="${pagesColumn}"

    ${pkgs.calibre}/bin/calibredb list --with-library "$LIBRARY" \
      -f "id,formats" --for-machine \
      -s "(#$PAGES_COLUMN:false or #$PAGES_COLUMN:=0)" \
    | ${pkgs.jq}/bin/jq -r '.[]
        | . as $b
        | ($b.formats // [] | map(select(test("\\.epub$"; "i"))) | first) as $epub
        | select($epub != null)
        | "\($b.id)\t\($epub)"' \
    | while IFS=$'\t' read -r book_id epub_path; do
        tmpdir=$(mktemp -d)
        mobi_path="$tmpdir/book.mobi"

        if ! ${pkgs.calibre}/bin/ebook-convert "$epub_path" "$mobi_path" >/dev/null 2>&1; then
          echo "Book $book_id: conversion failed"
          rm -rf "$tmpdir"
          continue
        fi

        pages=$(${pkgs.calibre}/bin/calibre-debug -c "
    from calibre.devices.kindle.apnx_page_generator.generators.accurate_page_generator import AccuratePageGenerator
    generator = AccuratePageGenerator.instance
    pages = generator.generate('$mobi_path', None)
    print(pages.number_of_pages)
    " 2>/dev/null | tail -n1)

        rm -rf "$tmpdir"

        if [[ "$pages" =~ ^[0-9]+$ ]]; then
          ${pkgs.calibre}/bin/calibredb set_custom --with-library "$LIBRARY" "$PAGES_COLUMN" "$book_id" "$pages"
          echo "Book $book_id: $pages pages"
        else
          echo "Book $book_id: page count failed"
        fi
      done
  '';
in
{

  systemd.services.cwa-pagecount = {
    description = "Count pages for new Calibre-Web-Automated books";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${cwa-pagecount}/bin/cwa-pagecount";
    };
  };

  systemd.timers.cwa-pagecount = {
    description = "Run cwa-pagecount every minute";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
    };
  };


  # manual pagecount:   sudo systemctl start cwa-pagecount.service
}