{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  homeDirectory =
    if pkgs.stdenv.isDarwin then "/Users/${config.home.username}" else "/home/${config.home.username}";
in
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
    ../../features/development/vim
    ../../features/development/git
    ./userinfo.nix
  ];

  news.display = "silent";
  home = {
    inherit homeDirectory;
    preferXdgDirectories = true;
  };

  programs.eza.enable = true;
  programs.git =
    let
      u = config.userinfo;
    in
    {
      userName = u.name;
      userEmail = builtins.head u.email;
      signing = {
        key = (builtins.head u.pgp).id;
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
    age.sshKeyPaths = [ "${homeDirectory}/.ssh/id_ed25519" ];
    age.keyFile = "${homeDirectory}/.config/sops/age/keys.txt";
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

  nix =
    {
      package = lib.mkDefault pkgs.nix;
      settings = {
        use-xdg-base-directories = true;
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        substituters = [
          "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
          "https://mirror.sjtu.edu.cn/nix-channels/store"
          "https://cache.nixos.org"
        ];
      };
    }
    // lib.optionalAttrs (config.sops.secrets ? nix-access-tokens) {
      extraOptions = "!include ${config.sops.secrets.nix-access-tokens.path}";
    };
}
