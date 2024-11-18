{
  lib,
  inputs,
  config,
  ...
}:
with lib;
{
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
  ];
  options = {
    boot.secureboot.enable = mkEnableOption "Enable secureboot";
  };
  config = mkIf (config.boot.secureboot.enable) {
    boot = {
      initrd.systemd.enable = true;
      loader = {
        systemd-boot = {
          enable = false;
          configurationLimit = 5;
          editor = false;
        };
        efi.canTouchEfiVariables = true;
        timeout = 3;
      };
      lanzaboote = {
        enable = true;
        pkiBundle = "/etc/secureboot";
      };
    };
  };
}
