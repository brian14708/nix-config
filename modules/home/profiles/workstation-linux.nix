{ config, ... }:
let
  hm = config.flake.modules.homeManager;
in
{
  flake.modules.homeManager.workstation-linux =
    { config, pkgs, ... }:
    {
      imports = [ hm.sops ];

      home.packages = [ pkgs.rclone ];

      xdg.configFile."rclone/rclone.conf".text = ''
        [lab-oss]
        type = s3
        provider = Alibaba
        env_auth = true
        profile = lab-oss
        endpoint = oss-cn-beijing.aliyuncs.com
        no_check_bucket = true

        [lab]
        type = alias
        remote = lab-oss:lab-bistro
      '';

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
