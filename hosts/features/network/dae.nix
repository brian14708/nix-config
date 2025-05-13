{
  config,
  ...
}:
{
  imports = [ ./dns.nix ];

  services.dae = {
    enable = true;
    configFile = config.sops.templates."config.dae".path;
  };
  sops.templates."config.dae".content = ''
    global {
        tproxy_port: 12345
        tproxy_port_protect: true
        pprof_port: 0
        so_mark_from_dae: 0
        log_level: warn
        disable_waiting_network: false
        enable_local_tcp_fast_redirect: false

        lan_interface: docker0,podman0
        wan_interface: auto
        auto_config_kernel_parameter: true

        tcp_check_url: 'http://cp.cloudflare.com,1.1.1.1,2606:4700:4700::1111'
        tcp_check_http_method: HEAD

        udp_check_dns: 'dns.google:53,8.8.8.8,2001:4860:4860::8888'
        check_interval: 30s
        check_tolerance: 50ms

        dial_mode: domain+
        allow_insecure: true
        sniffing_timeout: 100ms
        tls_implementation: tls
        utls_imitate: chrome_auto
    }

    subscription {
        "${config.sops.placeholder.dae-url}"
    }

    dns {
        upstream {
            local: 'udp://127.0.0.1:53'
        }
        routing {
            request {
                fallback: local
            }
        }
    }

    group {
        default {
            filter: name(regex: "(?i)(新|sg|singapore美|us|unitedstates|united states|japan|jp|japan)")
            policy: min_moving_avg
        }
    }

    routing {
        pname(NetworkManager) -> direct
        dscp(4) -> direct
        dip(224.0.0.0/3, 'ff00::/8') -> direct
        dip(geoip:private) -> direct

        domain(geosite:category-ads) -> block
        domain(geosite:cn) -> direct
        dip(geoip:cn) -> direct

        l4proto(udp) && dport(443) -> block
        fallback: default
    }
  '';
}
