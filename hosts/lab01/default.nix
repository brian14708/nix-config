{
  pkgs,
  inputs,
  outputs,
  machine,
  ...
}:
let
  stateVersion = "24.11";
in
{
  imports = [
    ../aliyun
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
    openssh.authorizedKeys.keys = (import ../../home/brian/_user.nix).ssh;
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
}
