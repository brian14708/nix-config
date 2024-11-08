{
  pkgs,
  inputs,
  outputs,
  machine,
  modulesPath,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ../aliyun
  ];

  networking = {
    hostName = "lab01";
  };

  users.mutableUsers = false;
  users.users.brian = {
    uid = 1000;
    description = "Brian";
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialPassword = "";
    openssh.authorizedKeys.keys = [
      "cert-authority,principals=\"me@brian14708.dev\" ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDeS6dWCB0TwwnmL6ynrQuLr5jsqS0dwjuwgw3FLen9P1hg+PMhwyw2G7ABfogZHwNG5y2jvB5iLfclrKPDQ/B31oJeWMV5hilDIiTLPTtIqKd93QQujyyLUqznC3dYNzJC7vBr0HGcR6te90Fjk80vsfFUQ/kE3PVJVGguhZI9TX9T2JepOlyQ597NSNuNkx7GUG9vrdZwxkyC3PUu2ipyLOvmLTiRPgl0wLXoIHUTgt0GfM5KpF3tlSirrWBu9WFdfL37YDvQt7JhqmsIXuUusNRw95HlROTujjV5xgWmv59t7TIdWRO3M2wzNQ257Wd3TZXmoYyk5TSzLvIWXb9dW0KlK4u8xaK0CU/H4Ro30coWveujmCX3jAxfAFpCSDHsy79JX/MIi43HnLJjvBY+1/VCwKwGUyXajq8/5XOCdBYYcQcNzfvWPoA2j8VlkxgaMHQ7i5tUy2dAHzKdJDmfuSyDrHEzfgGpAna8NaRbH5WKMpxX7dmlgmI0kWOw1nojfC8CCJyfEYPS81b7m9Z65C0+m+zhruUY9A/v3MdmwHlnkMMFmLHaavJSxK1U1ROGs/MYEiauBZiYiFPXbJnDNrU7hujTwdXvO5adJO8oZ9byOazB09vnRNQgc/X6hIas2Fh13tQ8NMbqZGWLcmfH6LkdjrVloRbbV7QtU0GCGQ=="
    ];
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.brian = {
    imports = [ ../../home/brian/generic.nix ];
  };
  home-manager.extraSpecialArgs = {
    inherit inputs outputs machine;
  };

  environment.systemPackages = with pkgs; [
    git
    gnumake
    tmux
  ];
}
