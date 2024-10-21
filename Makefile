.PHONY: nixos home

home:
	nix run nixpkgs#nh -- home switch .

nixos:
	nix run nixpkgs#nh -- os switch .
