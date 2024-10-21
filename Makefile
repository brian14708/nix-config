.PHONY: nixos home

nixos:
	nix run nixpkgs#nh -- os switch .

home:
	nix run nixpkgs#nh -- home switch .
