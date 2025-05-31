home:
    nh home switch .

nixos:
    nh os switch .

darwin:
    nh darwin switch .

lab:
    cd infra/lab && [ -d .terraform ] || SOPS_GPG_EXEC=/dev/null sops exec-env ./env.secrets.yaml 'tofu init'
    cd infra/lab && SOPS_GPG_EXEC=/dev/null sops exec-env ./env.secrets.yaml 'tofu apply'

image-lab-aliyun:
    nix build .#nixosConfigurations.lab-aliyun.config.system.build.qcow2

update:
    nix flake update
    nix-update --file ./pkgs/default.nix --version=branch=main rime-ice
    nix-update --file ./pkgs/default.nix --version=branch=main nix-store-gateway
    nix-update --file ./pkgs/default.nix --version=branch=master dnsmasq-china-list

gc:
    nh clean all

cache:
    nix copy --to http://[::1]:4444 \
        .#devShells.x86_64-linux.default \
        .#nixosConfigurations.fuxi.config.system.build.toplevel \
        .#nixosConfigurations.shiva.config.system.build.toplevel \
        .#homeConfigurations.brian@fuxi.activationPackage \
        .#homeConfigurations.brian@shiva.activationPackage
