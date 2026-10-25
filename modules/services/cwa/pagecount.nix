{ ... }:
{
  flake.modules.nixos.cwa-pagecount = { pkgs, config, ... }: {
    # drop TTS: piper-tts -> pyopenjtalk-plus fails tests on python 3.14
    nixpkgs.overlays = [
      (final: prev: {
        calibre = prev.calibre.override { speechSupport = false; };
      })
    ];

    # manual pagecount:   sudo systemctl start cwa-pagecount.service
    systemd.services.cwa-pagecount = {
      description = "Count pages for new Calibre-Web-Automated books";
      startAt = "hourly";
      path = [ pkgs.calibre pkgs.jq ];
      script = ''
        library=${config.cwa.dir}/library
        column=page_count

        calibredb list --with-library "$library" -f formats --for-machine \
          -s "(#$column:false or #$column:=0)" \
        | jq -r '.[]
            | (.formats // [] | map(select(test("\\.epub$"; "i"))) | first) as $epub
            | select($epub != null)
            | "\(.id)\t\($epub)"' \
        | while IFS=$'\t' read -r book_id epub_path; do
            tmpdir=$(mktemp -d)
            pages=$(ebook-convert "$epub_path" "$tmpdir/book.mobi" >/dev/null 2>&1 && calibre-debug -c "
      from calibre.devices.kindle.apnx_page_generator.generators.accurate_page_generator import AccuratePageGenerator
      pages = AccuratePageGenerator.instance.generate('$tmpdir/book.mobi', None)
      print(pages.number_of_pages)
      " 2>/dev/null | tail -n1) || true
            rm -rf "$tmpdir"

            if [[ "$pages" =~ ^[0-9]+$ ]]; then
              calibredb set_custom --with-library "$library" "$column" "$book_id" "$pages"
              echo "Book $book_id: $pages pages"
            else
              echo "Book $book_id: page count failed"
            fi
          done
      '';
    };
    systemd.timers.cwa-pagecount.timerConfig.Persistent = true;
  };
}
