.PHONY: nixos home

home:
	nix run nixpkgs#nh -- home switch . -- --accept-flake-config

nixos:
	nix run nixpkgs#nh -- os switch . -- --accept-flake-config

vm:
	nix run nixpkgs#nixos-rebuild -- build-vm --accept-flake-config --flake .#vmtest
	./result/bin/run-nixos-vm

lab:
	cd infra/lab && [ -d .terraform ] || sops exec-env ./env.secret.yaml 'tofu init'
	cd infra/lab && sops exec-env ./env.secret.yaml 'tofu apply'
