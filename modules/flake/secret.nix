{ inputs, ... }:
{
  flake-file.inputs.sops-nix = {
    url = "github:Mic92/sops-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.sops =
    { ... }:
    {
      imports = [ inputs.sops-nix.nixosModules.sops ];
      sops = {
        age.sshKeyPaths = [ ];
        age.keyFile = "/var/lib/sops-nix/keys.txt";
        gnupg.sshKeyPaths = [ ];
        defaultSopsFile = inputs.self + /configs/secrets.yaml;

        secrets = {
          # Shared config secrets (migrated from nix.orig/*/secrets.yaml).
          #
          # NOTE: Per-host secrets (password/ssh/sops key) are defined by the
          # relevant host modules (e.g. `nixos.workstation`) so non-workstation
          # configs can import `nixos.sops` without requiring those keys.
          "configs/mihomo-url" = { };
          "configs/dae-url" = { };
          "configs/smartdns" = { };
          "configs/unbound" = {
            mode = "0444";
          };
        };
      };
    };

  flake.modules.homeManager.sops =
    { config, ... }:
    {
      imports = [ inputs.sops-nix.homeManagerModules.sops ];
      sops = {
        environment.SOPS_GPG_EXEC = "/dev/null";
        age.sshKeyPaths = [ ];
        age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
        gnupg.sshKeyPaths = [ ];
        defaultSopsFile = inputs.self + /configs/secrets.yaml;
        secrets = {
          "configs/nix-store-gateway" = { };
          "configs/nix-access-tokens" = { };
          "configs/nix-secret-key" = { };
          "configs/ai" = { };
        };
      };
    };
}
