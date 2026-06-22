{ config, ... }:
let
  hm = config.flake.modules.homeManager;
in
{
  flake.modules.homeManager.workstation-linux =
    { config, ... }:
    {
      imports = [ hm.sops ];

      programs = {
        go = {
          enable = true;
          env.GOPATH = "${config.home.homeDirectory}/.local/go";
        };

        tmux = {
          enable = true;
          mouse = true;
          keyMode = "vi";
          terminal = "tmux-256color";
          focusEvents = true;
        };
      };
    };
}
