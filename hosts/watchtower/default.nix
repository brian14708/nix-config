{
  config,
  pkgs,
  inputs,
  outputs,
  ...
}:
let
  stateVersion = "24.11";
  tls-cert =
    cn:
    (pkgs.runCommand "selfSignedCert" { buildInputs = [ pkgs.openssl ]; } ''
      mkdir -p $out
      openssl req -x509 -newkey ec -pkeyopt ec_paramgen_curve:secp384r1 -days 3650 -nodes \
        -keyout $out/cert.key -out $out/cert.crt -subj "/CN=${cn}"
    '');

in
{
  imports = [
    ../profiles/aliyun
  ];

  system = {
    inherit stateVersion;
  };
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking = {
    hostName = "watchtower";
  };

  users.users.brian = {
    uid = 1000;
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = config.userinfos.brian.ssh;
  };

  services.tailscale.derper = {
    enable = true;
    domain = "derp-901";
    stunPort = 58583;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.brian = {
      imports = [
        ../../home/brian/profiles/base
      ];
      home = {
        inherit stateVersion;
        username = "brian";
      };
    };
    extraSpecialArgs = {
      inherit inputs outputs;
      machine = {
        trusted = false;
      };
    };
  };

  environment.systemPackages = with pkgs; [
    tmux
  ];

  services.nginx = {
    enable = true;
    package = pkgs.nginxMainline;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    recommendedBrotliSettings = true;
    recommendedGzipSettings = true;
    recommendedZstdSettings = true;
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
  networking.firewall = {
    allowedTCPPorts = [
      47321
    ];
  };

  services.cloudflared.enable = true;
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
      User = config.services.cloudflared.user;
      Group = config.services.cloudflared.group;
      LoadCredential = "TUNNEL_TOKEN:/var/secrets/cloudflare_tunnel";
      Restart = "on-failure";
      Type = "notify";
      RestartSec = "5s";
    };
  };
}
