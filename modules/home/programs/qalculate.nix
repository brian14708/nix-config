{ moduleWithSystem, ... }:
{
  flake.modules.homeManager.qalculate = moduleWithSystem (
    { self', ... }: {
      programs.qalculate = {
        enable = true;
        package = self'.packages.qalc;
      };
    }
  );

  perSystem =
    {
      pkgs,
      lib,
      ...
    }:
    {
      packages.qalc = pkgs.symlinkJoin {
        pname = "qalc";
        inherit (pkgs.libqalculate) version;
        paths = [ pkgs.libqalculate ];
        nativeBuildInputs = [
          pkgs.makeWrapper
          pkgs.python3
        ];
        postBuild = ''
          # Extend the packaged definitions while keeping user data writable.
          python3 - <<'PY'
          import os
          from pathlib import Path
          import xml.etree.ElementTree as ET

          for name in ("units", "variables"):
              destination = Path(os.environ["out"]) / "share/qalculate" / f"{name}.xml"
              tree = ET.parse(destination)
              tree.getroot().extend(ET.parse(Path("${../../../configs/qalculate}") / f"{name}.xml").getroot())
              destination.unlink()
              tree.write(destination, encoding="utf-8", xml_declaration=True)
          PY

          wrapProgram "$out/bin/qalc" \
            --set QALCULATE_DEFINITIONS_DIR "$out/share/qalculate" \
            --prefix PATH : ${lib.makeBinPath [ pkgs.gnuplot ]} \
            --run '
              if [ -z "''${GNUTERM:-}" ]; then
                if [ -t 1 ] && [ "''${TERM:-}" = xterm-kitty ]; then
                  export GNUTERM=kittycairo
                else
                  export GNUTERM=dumb
                fi
              fi
            '
        '';
        meta = pkgs.libqalculate.meta // {
          mainProgram = "qalc";
        };
      };
    };
}
