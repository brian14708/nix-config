{
  inputs,
  outputs,
  ...
}:
{
  imports = [
    ./userinfos.nix
    ./boot/secureboot.nix
  ];
  config = {
    home-manager = {
      sharedModules = [
        ../home-manager
      ];
      extraSpecialArgs = {
        inherit inputs outputs;
      };
    };
  };
}
