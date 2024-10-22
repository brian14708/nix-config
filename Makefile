.PHONY: nixos home

home:
	nix run nixpkgs#nh -- home switch .

nixos:
	nix run nixpkgs#nh -- os switch .

vm:
	nix run nixpkgs#nixos-rebuild -- build-vm --flake .#vmtest
	./result/bin/run-nixos-vm
