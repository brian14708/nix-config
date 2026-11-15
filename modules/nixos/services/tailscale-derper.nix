{
  flake.modules.nixos.tailscale-derper =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      domain = config.services.tailscale.derper.domain;
      certificate = "/var/lib/nginx/derper.pem";
      openssl = lib.getExe pkgs.openssl;
    in
    {
      services.nginx.virtualHosts.${domain} = {
        sslCertificate = certificate;
        sslCertificateKey = certificate;
      };

      # Reuse nginx's runtime state directory; private material never enters the store.
      services.nginx.preStart = ''
        (
          set -euo pipefail
          umask 077
          certificate="$STATE_DIRECTORY/derper.pem"
          if [ -s "$certificate" ] \
            && ${openssl} x509 -in "$certificate" -noout -checkend 86400 \
            && ${openssl} x509 -in "$certificate" -noout -checkhost ${lib.escapeShellArg domain} \
            && ${openssl} pkey -in "$certificate" -noout -check; then
            exit 0
          fi

          temporary=$(mktemp -d "$STATE_DIRECTORY/.certificate.XXXXXX")
          trap 'rm -rf "$temporary"' EXIT
          ${openssl} req -x509 -newkey ec -pkeyopt ec_paramgen_curve:secp384r1 \
            -days 3650 -nodes \
            -keyout "$temporary/key.pem" -out "$temporary/cert.pem" \
            -subj ${lib.escapeShellArg "/CN=${domain}"} \
            -addext ${lib.escapeShellArg "subjectAltName=DNS:${domain}"}
          cat "$temporary/cert.pem" "$temporary/key.pem" > "$temporary/certificate.pem"
          mv "$temporary/certificate.pem" "$certificate"
        )
      '';
    };
}
