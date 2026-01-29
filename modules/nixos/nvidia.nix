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
        nvidia-container-toolkit.enable = true;
      };
      nixpkgs.config.allowUnfreePackages = [
        "nvidia-x11"
        "nvidia-settings"
      ];
      services.xserver.videoDrivers = [
        "nvidia"
        "mesa"
      ];
    };
}
