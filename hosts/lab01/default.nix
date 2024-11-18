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
    inputs.home-manager.nixosModules.home-manager
    ../profiles/aliyun.nix
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
}
