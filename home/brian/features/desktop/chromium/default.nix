{
  programs.chromium = {
    enable = true;
    commandLineArgs = [
      "--enable-wayland-ime"
      "--ignore-gpu-blocklist"
      "--enable-gpu-rasterization"
      "--enable-oop-rasterization"
      "--enable-zero-copy"
      "--enable-accelerated-video-decode"
      "--password-store=basic"
      "--disable-sync-preferences"
      "--enable-features=WebUIDarkMode,AcceleratedVideoEncoder,AcceleratedVideoDecodeLinuxGL,AcceleratedVideoDecodeLinuxZeroCopyGL,VaapiIgnoreDriverChecks,PlatformHEVCDecoderSupport,UseMultiPlaneFormatForHardwareVideo"
      "--disable-features=UseChromeOSDirectVideoDecoder"
    ];
    extensions = [
      # 1Password
      { id = "aeblfdkhhhdcdjpifhhbdiojplfjncoa"; }
      # uBlock Origin Lite
      { id = "ddkjiahejlhfcafbddmgiahcphecmpfh"; }
      # Vimium
      { id = "dbepggeogbaibhgnhhndojpepiihcmeb"; }
    ];
  };
}
