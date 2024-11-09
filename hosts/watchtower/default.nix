{
  pkgs,
  inputs,
  outputs,
  machine,
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
    ../base/aliyun
  ];

  system = {
    inherit stateVersion;
  };

  networking = {
    hostName = "watchtower";
  };

  users.users.brian = {
    uid = 1000;
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = (import ../../home/brian/_user.nix).ssh;
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
      imports = [ ../../home/brian/common ];
      home = {
        inherit stateVersion;
        username = "brian";
      };
    };
    extraSpecialArgs = {
      inherit inputs outputs machine;
    };
  };

  environment.systemPackages = with pkgs; [
    tmux
  ];

  services.nginx = {
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
    };
  };
  networking.firewall = {
    allowedTCPPorts = [
      47321
    ];
  };
}
