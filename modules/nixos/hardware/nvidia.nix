{
  flake.modules.nixos.nvidia =
    { pkgs, ... }:
    {
      hardware = {
        graphics.enable = true;
        nvidia = {
          open = true;
          package = pkgs.linuxPackages_latest.nvidiaPackages.latest;
        };
      };
      services.xserver.videoDrivers = [
        "nvidia"
        "mesa"
      ];
    };
}
