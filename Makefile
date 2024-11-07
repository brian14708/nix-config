.PHONY: nixos home

home:
	nix run nixpkgs#nh -- home switch . -- --accept-flake-config

nixos:
	nix run nixpkgs#nh -- os switch . -- --accept-flake-config

vm:
	nix run nixpkgs#nixos-rebuild -- build-vm --accept-flake-config --flake .#vmtest
	./result/bin/run-nixos-vm

lab:
	cd infra/lab && [ -d .terraform ] || nix run nixpkgs#sops exec-env ./env.secret.yaml 'nix run nixpkgs#opentofu init'
	cd infra/lab && nix run nixpkgs#sops exec-env ./env.secret.yaml 'nix run nixpkgs#opentofu apply'
