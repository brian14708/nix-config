home:
	nh home switch .

nixos:
	nh os switch .

darwin:
	darwin-rebuild switch --flake .

lab:
	cd infra/lab && [ -d .terraform ] || SOPS_GPG_EXEC=/dev/null sops exec-env ./env.secret.yaml 'tofu init'
	cd infra/lab && SOPS_GPG_EXEC=/dev/null sops exec-env ./env.secret.yaml 'tofu apply'

aliyun-base:
	nix build .#nixosConfigurations.aliyun-base.config.system.build.qcow2
