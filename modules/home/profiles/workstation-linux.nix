{ config, ... }:
let
  hm = config.flake.modules.homeManager;
in
{
  flake.modules.homeManager.workstation-linux =
    { ... }:
    {
      imports = [ hm.sops ];

      programs.go.enable = true;

      programs.tmux = {
        enable = true;
        mouse = true;
      };
    };
}
