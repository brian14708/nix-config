{
  inputs,
  outputs,
  ...
}:
{
  imports = [
    inputs.home-manager.darwinModules.home-manager
    ./userinfos.nix
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
