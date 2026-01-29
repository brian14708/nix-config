{
  flake.modules.nixos.intel =
    { pkgs, ... }:
    {
      hardware.cpu.intel.updateMicrocode = true;
      system.stateVersion = "24.11";
      hardware.graphics = {
        enable = true;
        extraPackages = with pkgs; [
          vpl-gpu-rt
          intel-compute-runtime
          intel-media-driver
        ];
      };
    };
}
