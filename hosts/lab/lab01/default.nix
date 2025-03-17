{
  config,
  pkgs,
  inputs,
  outputs,
  ...
}:
let
  stateVersion = "24.11";
in
{
  imports = [
    ../base-aliyun.nix
  ];

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
    openssh.authorizedKeys.keys = config.userinfos.brian.ssh;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.brian = {
      imports = [
        ../../../home/brian/profiles/base
      ];
      home = {
        inherit stateVersion;
        username = "brian";
      };
    };
    extraSpecialArgs = {
      inherit inputs outputs;
    };
  };

  environment.systemPackages = with pkgs; [
    tmux
  ];

  virtualisation.containerd.enable = true;
  networking.firewall.enable = false;
  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv6.conf.all.forwarding" = true;
  };
}
