{
  pkgs,
  config,
  ...
}:
{
  networking.resolvconf.useLocalResolver = true;
  services.smartdns =
    let
      chinalist = pkgs.dnsmasq-china-list.override {
        format = "smartdns";
        server = "china";
      };
    in
    {
      enable = true;
      settings = {
        bind = [
          "127.0.0.1:53"
        ] ++ (if config.networking.enableIPv6 then [ "[::1]:53" ] else [ ]);

        cache-size = 4096;
        server = [
          "8.8.8.8 -bootstrap-dns"
          "1.1.1.1 -bootstrap-dns"
          "114.114.114.114 -bootstrap-dns"
          "223.5.5.5 -bootstrap-dns"
          "[fd7a:115c:a1e0::53] -group tailnet -exclude-default-group"
          "100.100.100.100 -group tailnet -exclude-default-group"
        ];

        conf-file =
          [
            "${chinalist}/accelerated-domains.china.smartdns.conf"
            "${chinalist}/google.china.smartdns.conf"
            "${chinalist}/apple.china.smartdns.conf"
          ]
          ++ (
            if config.sops.secrets ? smartdns then
              [
                "${config.sops.secrets."smartdns".path}"
              ]
            else
              [ ]
          );
        domain-rules = [
          "/.ts.net/ -nameserver tailnet"
        ];

        server-https = [
          "https://cloudflare-dns.com/dns-query"
          "https://dns.google/dns-query"
          "https://dns.quad9.net/dns-query"
          "https://185.222.222.222/dns-query"
          "https://1.1.1.1/dns-query"
          "https://45.11.45.11/dns-query"
          "https://ada.openbld.net/dns-query"
          "https://223.5.5.5/dns-query -group china -exclude-default-group"
          "https://doh.360.cn/dns-query -group china -exclude-default-group"
          "https://dns.pub/dns-query -group china -exclude-default-group"
        ];
        speed-check-mode = "none";
        prefetch-domain = true;
      };
    };

}
