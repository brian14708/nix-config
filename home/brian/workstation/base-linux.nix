{
  ...
}:
{
  imports = [
    ../profiles/base
  ];
  sops = {
    environment.SOPS_GPG_EXEC = "/dev/null";
    age.sshKeyPaths = [ ];
    age.keyFile = "/home/brian/.config/sops/age/keys.txt";
    gnupg.sshKeyPaths = [ ];
    secrets."ssh" = {
      path = "/home/brian/.ssh/id_ed25519";
    };
    secrets."nix-access-tokens" = {
      sopsFile = ./secrets.yaml;
    };
  };
  programs.go = {
    enable = true;
  };
}
