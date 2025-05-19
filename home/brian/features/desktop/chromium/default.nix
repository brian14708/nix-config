{ pkgs, ... }:
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

  home.packages = [ pkgs.captive-browser ];
  xdg.configFile."captive-browser.toml".text = ''
    browser = """
      ${pkgs.chromium}/bin/chromium \
        --user-data-dir=''${XDG_DATA_HOME:-$HOME/.local/share}/chromium-captive \
        --proxy-server="socks5://$PROXY" \
        --host-resolver-rules="MAP * ~NOTFOUND , EXCLUDE localhost" \
        --no-first-run --new-window --incognito \
        http://google.cn/generate_204
    """
    dhcp-dns = "${pkgs.networkmanager}/bin/nmcli dev show | ${pkgs.gnugrep}/bin/fgrep IP4.DNS"
    socks5-addr = "localhost:1666"
  '';
}
