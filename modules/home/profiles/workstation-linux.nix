{ config, ... }:
let
  hm = config.flake.modules.homeManager;
in
{
  flake.modules.homeManager.workstation-linux =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [ hm.sops ];

      home.packages = [ pkgs.rclone ];

      xdg.configFile."rclone/rclone.conf".text = lib.generators.toINI { } {
        lab = {
          type = "alias";
          remote = ":s3,provider=Alibaba,env_auth=true,profile=lab-oss,endpoint=oss-cn-beijing.aliyuncs.com,no_check_bucket=true:lab-bistro";
        };
      };

      # Keep non-secret AWS profile settings declarative. Credentials remain
      # in ~/.aws/credentials and are intentionally not managed by Nix.
      home.file.".aws/config" = {
        force = true;
        text = ''
          [profile nix-cache-miecho3l]
          region = cn-beijing
          output = json
          services = oss
          s3 =
              addressing_style = virtual

          [profile lab-oss]
          region = cn-beijing
          output = json
          services = oss
          s3 =
              addressing_style = virtual

          [services oss]
          s3 =
              endpoint_url = https://oss-cn-beijing.aliyuncs.com
        '';
      };

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
