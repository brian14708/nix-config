{ config, ... }:
let
  hm = config.flake.modules.homeManager;
in
{
  flake.modules.homeManager.base =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      inherit (config) owner;
      inherit (config.home) homeDirectory;
    in
    {
      imports = with hm; [
        git
        vim
        qalculate
        locale-cn
      ];

      news.display = "silent";

      home = {
        preferXdgDirectories = true;
        sessionVariables = {
          PAGER = "${pkgs.less}/bin/less -RXF";
        };
        sessionPath = [
          "${homeDirectory}/.local/bin"
        ];
      };

      services.ssh-agent.enable = !pkgs.stdenv.isDarwin;

      programs = {
        home-manager.enable = true;

        git = {
          settings = {
            user = {
              inherit (owner) name;
              email = builtins.head owner.email;
            };
          };
          signing.key = builtins.head owner.pgp;
        };

        jujutsu.settings.user = {
          inherit (owner) name;
          email = builtins.head owner.email;
        };

        ssh = {
          enable = true;
          enableDefaultConfig = false;
          matchBlocks."*" = {
            compression = true;
            addKeysToAgent = "yes";
          };
          extraConfig = ''
            ObscureKeystrokeTiming no
            StrictHostKeyChecking accept-new
            Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-gcm@openssh.com,aes128-ctr
            KexAlgorithms mlkem768x25519-sha256,sntrup761x25519-sha512@openssh.com,curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512,diffie-hellman-group-exchange-sha256
            MACs hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,umac-128-etm@openssh.com
            RequiredRSASize 2048
            HostKeyAlgorithms sk-ssh-ed25519-cert-v01@openssh.com,ssh-ed25519-cert-v01@openssh.com,rsa-sha2-512-cert-v01@openssh.com,rsa-sha2-256-cert-v01@openssh.com,sk-ssh-ed25519@openssh.com,ssh-ed25519,rsa-sha2-512,rsa-sha2-256
            CASignatureAlgorithms sk-ssh-ed25519@openssh.com,ssh-ed25519,rsa-sha2-512,rsa-sha2-256
            HostbasedAcceptedAlgorithms sk-ssh-ed25519-cert-v01@openssh.com,ssh-ed25519-cert-v01@openssh.com,sk-ssh-ed25519@openssh.com,ssh-ed25519,rsa-sha2-512-cert-v01@openssh.com,rsa-sha2-512,rsa-sha2-256-cert-v01@openssh.com,rsa-sha2-256
            PubkeyAcceptedAlgorithms sk-ssh-ed25519-cert-v01@openssh.com,ssh-ed25519-cert-v01@openssh.com,sk-ssh-ed25519@openssh.com,ssh-ed25519,rsa-sha2-512-cert-v01@openssh.com,rsa-sha2-512,rsa-sha2-256-cert-v01@openssh.com,rsa-sha2-256
          '';
          includes = [ "~/.ssh/config_*" ];
        };
      };

      xdg.userDirs = {
        documents = "${homeDirectory}/documents";
        download = "${homeDirectory}/downloads";
        music = "${homeDirectory}/music";
        pictures = "${homeDirectory}/pictures";
        videos = "${homeDirectory}/videos";
        desktop = "${homeDirectory}/desktop";
        publicShare = "${homeDirectory}/public";
        templates = "${homeDirectory}/templates";
      };

      nix = {
        settings = {
          use-xdg-base-directories = true;
          experimental-features = [
            "nix-command"
            "flakes"
          ];
        }
        // lib.optionalAttrs (config ? sops && config.sops.secrets ? "configs/nix-secret-key") {
          secret-key-files = [ config.sops.secrets."configs/nix-secret-key".path ];
        };
      }
      // lib.optionalAttrs (config ? sops && config.sops.secrets ? "configs/nix-access-tokens") {
        extraOptions = "!include ${config.sops.secrets."configs/nix-access-tokens".path}";
      }
      // lib.optionalAttrs pkgs.stdenv.isDarwin {
        package = pkgs.nixVersions.latest;
      };

      xdg.configFile = lib.optionalAttrs (!config.nix.enable) {
        "nix/nix.conf".source =
          let
            inherit (lib)
              boolToString
              concatStringsSep
              escape
              floatToString
              isBool
              isConvertibleWithToString
              isDerivation
              isFloat
              isInt
              isList
              isString
              mapAttrsToList
              toPretty
              ;
            mkValueString =
              v:
              if v == null then
                ""
              else if isInt v then
                toString v
              else if isBool v then
                boolToString v
              else if isFloat v then
                floatToString v
              else if isList v then
                toString v
              else if isDerivation v then
                toString v
              else if builtins.isPath v then
                toString v
              else if isString v then
                v
              else if isConvertibleWithToString v then
                toString v
              else
                abort "The nix conf value: ${toPretty { } v} can not be encoded";

            mkKeyValue = k: v: "${escape [ "=" ] k} = ${mkValueString v}";

            mkKeyValuePairs = attrs: concatStringsSep "\n" (mapAttrsToList mkKeyValue attrs);

            cfg = config.nix;
          in
          pkgs.writeTextFile {
            name = "nix.conf";
            text = ''
              # WARNING: this file is generated from the home-manager
              ${mkKeyValuePairs cfg.settings}
              ${cfg.extraOptions}
            '';
          };
      };
    };
}
