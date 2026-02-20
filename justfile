nix:
    #!/usr/bin/env sh
    if [ "$(uname)" = "Darwin" ]; then
        nh darwin switch .
    elif [ -e /etc/NIXOS ] || grep -q nixos /etc/os-release 2>/dev/null; then
        nh os switch .
    else
        nh home switch .
    fi

lab:
    #!/usr/bin/env bash
    set -euo pipefail
    cd infra/lab
    if [ ! -d .terraform ]; then
        SOPS_GPG_EXEC=/dev/null sops exec-env ./env.secrets.yaml 'tofu init'
    fi
    SOPS_GPG_EXEC=/dev/null sops exec-env ./env.secrets.yaml 'tofu apply'

image-lab-aliyun:
    nix build .#nixosConfigurations.lab-aliyun.config.system.build.qcow2

update:
    nix flake update
    nix run nixpkgs#nix-update -- --flake --version=branch=main rime-ice
    nix run nixpkgs#nix-update -- --flake --version=branch=master dnsmasq-china-list
    nix run .#write-flake

cache host='':
    #!/usr/bin/env sh
    set -eu
    dest='s3://nix-cache-miecho3l?endpoint=oss-cn-beijing.aliyuncs.com&addressing-style=virtual&profile=nix-cache-miecho3l'
    host='{{host}}'
    if [ -z "$host" ]; then
        host="$(hostname -s 2>/dev/null || hostname)"
    fi
    nix copy --to "$dest" \
        .#devShells.x86_64-linux.default \
        ".#nixosConfigurations.${host}.config.system.build.toplevel"
