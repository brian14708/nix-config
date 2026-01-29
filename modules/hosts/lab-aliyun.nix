{ config, ... }:
let
  inherit (config.flake.modules) nixos;
in
{
  flake.modules.nixos."hosts/lab-aliyun" =
    { ... }:
    {
      imports = with nixos; [
        lab-aliyun
      ];

      networking.hostName = "lab-aliyun";
    };
}
