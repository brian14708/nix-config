{
  flake.modules.nixos.intel =
    { pkgs, modulesPath, ... }:
    {
      imports = [
        (modulesPath + "/hardware/cpu/intel-npu.nix")
      ];
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
