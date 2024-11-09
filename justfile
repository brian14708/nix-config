home:
	nix run nixpkgs#nh -- home switch . -- --accept-flake-config

nixos:
	nix run nixpkgs#nh -- os switch . -- --accept-flake-config

lab:
	cd infra/lab && [ -d .terraform ] || nix run nixpkgs#sops exec-env ./env.secret.yaml 'nix run nixpkgs#opentofu init'
	cd infra/lab && SOPS_GPG_EXEC=/dev/null nix run nixpkgs#sops exec-env ./env.secret.yaml 'nix run nixpkgs#opentofu apply'

aliyun-image:
	nix build .#aliyun-image
