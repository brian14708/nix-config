{ config, inputs, ... }:
let
  inherit (config.flake.modules) nixos;
in
{
  flake.modules.nixos."hosts/watchtower" =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    let
      inherit (config) owner;
    in
    {
      imports = [
        inputs.sops-nix.nixosModules.sops
        nixos.lab-aliyun
        nixos.tailnet-ssh
        nixos.tailscale-derper
      ];

      # Watchtower is untrusted: it decrypts only secrets/lab.yaml, keyed by
      # its SSH host key so no age key needs to be provisioned. Deliberately
      # does NOT import the shared `sops` module, which would grant it the
      # secrets/workstation.yaml secrets as well.
      sops = {
        defaultSopsFile = inputs.self + /secrets/lab.yaml;
        age.keyFile = null;
        age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        gnupg.sshKeyPaths = [ ];
        secrets = {
          cloudflare-tunnel.restartUnits = [ "cloudflared-tunnel.service" ];
        };
      };

      networking = {
        hostName = "watchtower";
        firewall.allowedTCPPorts = [
          42222
          47321
        ];
        firewall.allowedUDPPorts = [
          47320
        ];
      };
      system.stateVersion = "24.11";

      environment.systemPackages = with pkgs; [
        tmux
      ];

      users.users.jump = {
        uid = 2001;
        isNormalUser = true;
        description = "SSH jump account";
        hashedPassword = "!";
        openssh.authorizedKeys.keys = owner.ssh;
      };

      services = {
        openssh = {
          ports = [
            22
            42222
          ];
          extraConfig = ''
            Match LocalPort 22
              AllowUsers ops

            Match LocalPort 42222
              AllowUsers jump
              AllowAgentForwarding no
              AllowStreamLocalForwarding no
              AllowTcpForwarding local
              GatewayPorts no
              MaxSessions 0
              PermitTunnel no
              PermitTTY no
              X11Forwarding no
          '';
        };

        tailscale = {
          enable = true;
          # Auth key is delivered via terraform cloud-init (infra/lab/main.tf).
          authKeyFile = "/var/secrets/tailscale_key";
          derper = {
            enable = true;
            domain = "derp-901";
            stunPort = 58583;
          };
          extraSetFlags = [
            "--accept-dns=false"
            "--relay-server-port=47320"
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
            "derp-901" = {
              listen = [
                {
                  addr = "0.0.0.0";
                  port = 47321;
                  ssl = true;
                }
              ];
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
      systemd.services.tailscaled-autoconnect.after = [ "cloud-final.service" ];
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
          exec ${lib.getExe pkgs.cloudflared} tunnel --no-autoupdate run \
            --token-file "$CREDENTIALS_DIRECTORY/TUNNEL_TOKEN"
        '';
        serviceConfig = {
          DynamicUser = true;
          LoadCredential = "TUNNEL_TOKEN:${config.sops.secrets.cloudflare-tunnel.path}";
          Restart = "on-failure";
          Type = "notify";
          RestartSec = "5s";
          RuntimeDirectory = "cloudflared-tunnel";
          RuntimeDirectoryMode = "0700";
        };
      };
    };
}
