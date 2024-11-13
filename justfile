home:
	nh home switch .

nixos:
	nh os switch .

darwin:
	darwin-rebuild switch --flake .

lab:
	cd infra/lab && [ -d .terraform ] || sops exec-env ./env.secret.yaml 'tofu init'
	cd infra/lab && sops exec-env ./env.secret.yaml 'tofu apply'

aliyun-base:
	nix build .#nixosConfigurations.aliyun-base.config.system.build.qcow2
