home:
    nh home switch .

nixos:
    nh os switch .

darwin:
    darwin-rebuild switch --flake .

lab:
    cd infra/lab && [ -d .terraform ] || SOPS_GPG_EXEC=/dev/null sops exec-env ./env.secrets.yaml 'tofu init'
    cd infra/lab && SOPS_GPG_EXEC=/dev/null sops exec-env ./env.secrets.yaml 'tofu apply'

image-lab-aliyun:
    nix build .#nixosConfigurations.lab-aliyun.config.system.build.qcow2

update:
    nix flake update
    nix-update --file ./pkgs/default.nix --version=branch=main rime-ice
    nix-update --file ./pkgs/default.nix --version=branch=master dnsmasq-china-list

gc:
    nh clean all
