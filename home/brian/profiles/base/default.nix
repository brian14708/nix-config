{
  config,
  pkgs,
  lib,
  inputs,
  machine,
  ...
}:
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
    ../../features/development/vim
    ../../features/development/git
    ./identity.nix
  ];

  news.display = "silent";
  home.preferXdgDirectories = true;
  home.homeDirectory =
    if pkgs.stdenv.isDarwin then "/Users/${config.home.username}" else "/home/${config.home.username}";

  programs.bat.enable = true;
  programs.eza.enable = true;
  programs.git = {
    userName = "Brian Li";
    userEmail = "me@brian14708.dev";
    signing = {
      key = "91C32271A5A151D38526881FD03DD6ED48DEE9CE";
    };
  };

  programs = {
    home-manager.enable = true;
    ssh = {
      enable = true;
      compression = true;
      extraConfig = ''
        StrictHostKeyChecking accept-new
        Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-gcm@openssh.com,aes128-ctr
        KexAlgorithms sntrup761x25519-sha512@openssh.com,curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512,diffie-hellman-group-exchange-sha256
        MACs hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,umac-128-etm@openssh.com
        RequiredRSASize 3072
        HostKeyAlgorithms sk-ssh-ed25519-cert-v01@openssh.com,ssh-ed25519-cert-v01@openssh.com,rsa-sha2-512-cert-v01@openssh.com,rsa-sha2-256-cert-v01@openssh.com,sk-ssh-ed25519@openssh.com,ssh-ed25519,rsa-sha2-512,rsa-sha2-256
        CASignatureAlgorithms sk-ssh-ed25519@openssh.com,ssh-ed25519,rsa-sha2-512,rsa-sha2-256
        HostbasedAcceptedAlgorithms sk-ssh-ed25519-cert-v01@openssh.com,ssh-ed25519-cert-v01@openssh.com,sk-ssh-ed25519@openssh.com,ssh-ed25519,rsa-sha2-512-cert-v01@openssh.com,rsa-sha2-512,rsa-sha2-256-cert-v01@openssh.com,rsa-sha2-256
        PubkeyAcceptedAlgorithms sk-ssh-ed25519-cert-v01@openssh.com,ssh-ed25519-cert-v01@openssh.com,sk-ssh-ed25519@openssh.com,ssh-ed25519,rsa-sha2-512-cert-v01@openssh.com,rsa-sha2-512,rsa-sha2-256-cert-v01@openssh.com,rsa-sha2-256
      '';
    };
  };

  sops = {
    gnupg.home = "${config.xdg.configHome}/sops-nix/gnupg";
    age.sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
  };

  sops.secrets = lib.optionalAttrs machine.trusted {
    "nix.conf" = {
      sopsFile = ./nix.secret.yaml;
    };
  };

  nix =
    {
      package = lib.mkDefault pkgs.nixVersions.latest;
      settings = {
        use-xdg-base-directories = !config.targets.genericLinux.enable;
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        substituters = [
          "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
          "https://mirror.sjtu.edu.cn/nix-channels/store"
          "https://brian14708.cachix.org"
          "https://cache.nixos.org"
        ];
        extra-trusted-public-keys = [
          "brian14708.cachix.org-1:ZTO1dfqDryBeRpLJwn/czQj0HFC0TPuV2aK+81o2mSs="
        ];
      };
    }
    // lib.optionalAttrs machine.trusted {
      extraOptions = "!include ${config.sops.secrets."nix.conf".path}\n";
      checkConfig = false;
    };
}
