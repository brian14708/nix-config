{
  flake.modules.nixos.nvidia =
    { config, ... }:
    {
      hardware = {
        graphics.enable = true;
        nvidia = {
          open = true;
          package = config.boot.kernelPackages.nvidiaPackages.latest;
        };
      };
      services.xserver.videoDrivers = [
        "nvidia"
        "mesa"
      ];
    };
}
