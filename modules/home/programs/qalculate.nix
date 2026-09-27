{ inputs, ... }:
{
  flake.modules.homeManager.qalculate = { pkgs, lib, ... }: {
    home.packages = [ pkgs.gnuplot ];

    programs.qalculate = {
      enable = true;
      package = pkgs.symlinkJoin {
        name = "qalculate-with-plotting";
        paths = [ pkgs.libqalculate ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram "$out/bin/qalc" \
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
        meta = pkgs.libqalculate.meta;
      };
      definitions = {
        units = inputs.self + /configs/qalculate/units.xml;
        variables = inputs.self + /configs/qalculate/variables.xml;
      };
    };
  };
}
