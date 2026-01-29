{ config, ... }:
let
  inherit (config.flake.modules) nixos;
in
{
  flake.modules.nixos."hosts/watchtower" =
    { pkgs, ... }:
    let
      tls-cert =
        cn:
        (pkgs.runCommand "selfSignedCert" { buildInputs = [ pkgs.openssl ]; } ''
          mkdir -p $out
          openssl req -x509 -newkey ec -pkeyopt ec_paramgen_curve:secp384r1 -days 3650 -nodes \
            -keyout $out/cert.key -out $out/cert.crt -subj "/CN=${cn}"
        '');
    in
    {
      imports = with nixos; [
        lab-aliyun
      ];

      networking = {
        hostName = "watchtower";
        firewall.allowedTCPPorts = [
          47321
        ];
      };
      system.stateVersion = "24.11";

      environment.systemPackages = with pkgs; [
        tmux
      ];

      services = {
        tailscale = {
          derper = {
            enable = true;
            domain = "derp-901";
            stunPort = 58583;
          };
          extraSetFlags = [
            "--accept-dns=false"
          ];
        };

        nginx = {
          enable = true;
          package = pkgs.nginxMainline;
          recommendedOptimisation = true;
          recommendedTlsSettings = true;
          recommendedBrotliSettings = true;
          recommendedGzipSettings = true;
          recommendedProxySettings = true;
          virtualHosts = {
            "derp-901" =
              let
                cert = tls-cert "derp-901";
              in
              {
                listen = [
                  {
                    addr = "0.0.0.0";
                    port = 47321;
                    ssl = true;
                  }
                ];
                sslCertificate = "${cert}/cert.crt";
                sslCertificateKey = "${cert}/cert.key";
              };
            "default" = {
              default = true;
              listen = [
                {
                  addr = "127.0.0.1";
                  port = 80;
                }
              ];
            };
          };
        };

        cloudflared.enable = true;
      };
      systemd.services.cloudflared-tunnel = {
        after = [
          "network.target"
          "network-online.target"
        ];
        wants = [
          "network.target"
          "network-online.target"
        ];
        wantedBy = [ "multi-user.target" ];
        script = ''
          export TUNNEL_TOKEN=$(${pkgs.systemd}/bin/systemd-creds cat TUNNEL_TOKEN)
          exec ${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate run
        '';
        serviceConfig = {
          DynamicUser = true;
          LoadCredential = "TUNNEL_TOKEN:/var/secrets/cloudflare_tunnel";
          Restart = "on-failure";
          Type = "notify";
          RestartSec = "5s";
          RuntimeDirectory = "cloudflared-tunnel";
          RuntimeDirectoryMode = "0400";
        };
      };
    };
}
