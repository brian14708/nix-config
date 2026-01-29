{
  flake.modules.nixos.intel =
    { pkgs, ... }:
    {
      hardware.cpu.intel.updateMicrocode = true;
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
