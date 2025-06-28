{
  pkgs,
  config,
  ...
}:
{
  imports = [ ./dns.nix ];

  services.mihomo = {
    enable = true;
    configFile = config.sops.templates."mihomo.yaml".path;
    webui = pkgs.metacubexd;
    tunMode = true;
  };

  sops.templates."mihomo.yaml".content = ''
    proxy-providers:
      proxy:
        type: http
        interval: 3600
        health-check:
          enable: true
          url: http://www.gstatic.com/generate_204
          interval: 300
        path: ./proxy_provider/proxy.yaml
        url: "${config.sops.placeholder.mihomo-url}"

    rule-providers:
      anti-ad:
        type: http
        behavior: domain
        format: yaml
        path: ./rule_provider/anti-ad.yaml
        url: "https://anti-ad.net/clash.yaml"
        interval: 86400
      proxy:
        type: http
        behavior: domain
        path: ./rule_provider/proxy.yaml
        url: "https://testingcf.jsdelivr.net/gh/Loyalsoldier/clash-rules@release/proxy.txt"
        interval: 86400

    ipv6: true
    log-level: info
    allow-lan: true
    mixed-port: 7890
    unified-delay: true
    tcp-concurrent: true
    external-controller: 127.0.0.1:9090
    geodata-mode: true
    geo-update-interval: 24
    geox-url:
      geoip: "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geoip.dat"
      geosite: "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geosite.dat"
      mmdb: "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/country.mmdb"
      asn: "https://testingcf.jsdelivr.net/gh/xishang0128/geoip@release/GeoLite2-ASN.mmdb"

    find-process-mode: strict
    global-client-fingerprint: chrome

    profile:
      store-selected: true
      store-fake-ip: true

    sniffer:
      enable: true
      sniff:
        TLS:
          ports: [443, 8443]
        QUIC:
          ports: [443, 8443]
        HTTP:
          ports: [80, 8080-8880]
          override-destination: true

    tun:
      enable: true
      stack: mixed
      auto-route: true
      auto-redirect: true
      auto-detect-interface: true
      strict-route: true
      exclude-interface:
        - podman0
        - docker0
      route-exclude-address:
        - 10.0.0.0/8
        - 100.64.0.0/10
        - 172.16.0.0/12
        - 192.168.0.0/16
        - fd7a:115c:a1e0::/48

    dns:
      enable: true
      default-nameserver:
        - 127.0.0.1

    proxy-groups:
      - name: default
        type: select
        proxies:
        - DIRECT
        - auto-fast
      - name: auto-fast
        type: url-test
        use:
        - proxy
        tolerance: 50
      - name: ai
        type: url-test
        proxies:
        - singapore
        - japan
        - usa

      # region
      - name: hongkong
        type: url-test
        use:
        - proxy
        filter: "(?i)港|hk|hongkong|hong kong"
      - name: japan
        type: url-test
        use:
        - proxy
        filter: "(?i)japan|jp|japan"
      - name: usa
        type: url-test
        use:
        - proxy
        filter: "(?i)美|us|unitedstates|united states"
      - name: UK
        type: url-test
        use:
        - proxy
        filter: "(?i)英|uk|unitedkingdom|united kingdom"
      - name: singapore
        type: url-test
        use:
        - proxy
        filter: "(?i)(新|sg|singapore)"
      - name: other-region
        type: url-test
        use:
        - proxy
        filter: "(?i)^(?!.*(?:🇭🇰|🇯🇵|🇺🇸|🇸🇬|🇨🇳|港|hk|hongkong|台|tw|taiwan|日|jp|japan|新|sg|singapore|美|us|unitedstates|英|uk|unitedkingdom)).*"
      - name: all
        type: url-test
        use:
        - proxy

    rules:
      - GEOIP,private,DIRECT,no-resolve
      - GEOSITE,private,DIRECT,no-resolve
      - RULE-SET,anti-ad,REJECT
      - AND,(AND,(DST-PORT,443),(NETWORK,UDP)),(NOT,((GEOSITE,cn))),REJECT

      - GEOSITE,category-ai-chat-!cn,ai
      - GEOSITE,CN,DIRECT
      - RULE-SET,proxy,auto-fast
      - GEOIP,CN,DIRECT
      - MATCH,default
  '';
}
