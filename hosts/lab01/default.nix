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
    {
      alt ? [ ],
    }:
    (pkgs.runCommand "selfSignedCert" { buildInputs = [ pkgs.openssl ]; } ''
      mkdir -p $out
      openssl req -x509 -newkey ec -pkeyopt ec_paramgen_curve:secp384r1 -days 3650 -nodes \
        -keyout $out/cert.key -out $out/cert.crt \
        -subj "/CN=localhost" -addext "subjectAltName=DNS:localhost,${
          builtins.concatStringsSep "," ([ "IP:127.0.0.1" ] ++ alt)
        }"
    '');

in
{
  imports = [
    ../aliyun
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
  };
  system = {
    inherit stateVersion;
  };

  networking = {
    hostName = "lab01";
  };

  users.users.brian = {
    uid = 1000;
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = (import ../../home/brian/_user.nix).ssh;
  };

  services.tailscale.derper = {
    enable = true;
    verifyClients = true;
    domain = "derp-902";
    port = 54369;
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
    git
    gnumake
    tmux
  ];

  services.nginx = {
    virtualHosts = {
      "derp-902" =
        let
          cert = tls-cert { alt = [ "DNS:derp-902" ]; };
        in
        {
          sslCertificate = "${cert}/cert.crt";
          sslCertificateKey = "${cert}/cert.key";
        };
    };
  };
}
