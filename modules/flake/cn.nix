{ inputs, lib, ... }:
let
  # Homebrew Mirror
  homebrew_mirror_env = {
    HOMEBREW_API_DOMAIN = "https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles/api";
    HOMEBREW_BOTTLE_DOMAIN = "https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles";
    HOMEBREW_BREW_GIT_REMOTE = "https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git";
    HOMEBREW_CORE_GIT_REMOTE = "https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git";
    HOMEBREW_PIP_INDEX_URL = "https://pypi.tuna.tsinghua.edu.cn/simple";
  };

  registrySuffixes = {
    "docker.io" = "";
    "quay.io" = "-quay";
    "nvcr.io" = "-nvcr";
    "registry.k8s.io" = "-k8s";
    "k8s.gcr.io" = "-k8s";
    "mcr.microsoft.io" = "-mcr";
    "docker.elastic.co" = "-elastic";
    "container-registry.oracle.com" = "-oracle";
    "registry.gitlab.com" = "-gitlab";
    "gcr.io" = "-gcr";
    "ghcr.io" = "-ghcr";
  };

  mirrorHost = prefix: registry: "${prefix}${registrySuffixes.${registry}}.xuanyuan.run";
  upstreamHost = registry: if registry == "docker.io" then "registry-1.docker.io" else registry;

  buildkitRegistryConfig =
    prefix:
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList (registry: _: ''
        [registry."${registry}"]
          mirrors = ["${mirrorHost prefix registry}"]
      '') registrySuffixes
    );

  containersRegistryConfig = prefix: ''
    unqualified-search-registries = ["docker.io"]

    ${lib.concatStringsSep "\n" (
      lib.mapAttrsToList (registry: _: ''
        [[registry]]
        prefix = "${registry}"
        location = "${upstreamHost registry}"

        [[registry.mirror]]
        location = "${mirrorHost prefix registry}"
      '') registrySuffixes
    )}
  '';

  dockerRegistryConfig =
    prefix:
    builtins.toJSON {
      "registry-mirrors" = [ "https://${mirrorHost prefix "docker.io"}" ];
    };

  containersPolicy = {
    default = [ { type = "insecureAcceptAnything"; } ];
  };

  withWorkstationSops =
    config: options: body:
    lib.optionalAttrs (options ? sops) (
      lib.mkIf (config.sops.defaultSopsFile == inputs.self + /secrets/workstation.yaml) body
    );
in
{
  flake.modules = {
    darwin.locale-cn = {
      # Set variables for you to manually install homebrew packages.
      environment.variables = homebrew_mirror_env;

      # Set environment variables for nix-darwin before run `brew bundle`.
      system.activationScripts.homebrew.text =
        let
          env_script = lib.attrsets.foldlAttrs (
            acc: name: value:
            acc + "\nexport ${name}=${value}"
          ) "" homebrew_mirror_env;
        in
        lib.mkBefore ''
          echo >&2 '${env_script}'
          ${env_script}
        '';
    };

    nixos.locale-cn =
      {
        config,
        lib,
        options,
        ...
      }:
      let
        buildkitEnabled = config.systemd.services ? buildkit || config.systemd.services ? buildkitd;
        dockerEnabled = config.virtualisation.docker.enable;
        k3sEnabled = config.services.k3s.enable;
        podmanEnabled = config.virtualisation.podman.enable;
      in
      lib.mkMerge [
        {
          i18n.defaultLocale = "en_US.UTF-8";
          time.timeZone = "Asia/Hong_Kong";
          nix.settings = {
            substituters = [
              "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store?priority=10"
              "https://mirrors.ustc.edu.cn/nix-channels/store?priority=20"
              "https://cache.nixos.org?priority=100"
            ];
          };
        }

        # SOPS is intentionally not imported here: some locale-cn hosts use a
        # separate lab secrets file. Configure Xuanyuan only on workstations
        # that already have their own SOPS decryption key.
        (withWorkstationSops config options (
          let
            prefix = config.sops.placeholder."configs/xuanyuan";

            k3sMirrors = lib.mapAttrs (registry: _: {
              endpoint = [ "https://${mirrorHost prefix registry}" ];
            }) registrySuffixes;

          in
          lib.mkMerge [
            {
              sops.secrets."configs/xuanyuan" = { };
            }

            (lib.mkIf buildkitEnabled {
              sops.templates."buildkitd.toml".content = buildkitRegistryConfig prefix;
              environment.etc."buildkit/buildkitd.toml".source = config.sops.templates."buildkitd.toml".path;
            })

            (lib.mkIf dockerEnabled {
              sops.templates."docker-xuanyuan.env" = {
                content = ''
                  XUANYUAN_PREFIX=${prefix}
                '';
                restartUnits = [ "docker.service" ];
              };

              systemd.services.docker = {
                after = [ "sops-install-secrets.service" ];
                wants = [ "sops-install-secrets.service" ];
                serviceConfig.EnvironmentFile = config.sops.templates."docker-xuanyuan.env".path;
              };

              virtualisation.docker.extraOptions = "--registry-mirror=https://\${XUANYUAN_PREFIX}.xuanyuan.run";
            })

            (lib.mkIf podmanEnabled {
              virtualisation.containers.policy = containersPolicy;

              sops.templates."containers-registries.conf" = {
                mode = "0444";
                content = containersRegistryConfig prefix;
              };

              environment.etc."containers/registries.conf".source = lib.mkForce (
                config.sops.templates."containers-registries.conf".path
              );
            })

            (lib.mkIf k3sEnabled {
              sops.templates."k3s-registries.yaml" = {
                content = builtins.toJSON {
                  mirrors = k3sMirrors;
                  configs = { };
                };
                restartUnits = [ "k3s.service" ];
              };
              environment.etc."rancher/k3s/registries.yaml".source =
                config.sops.templates."k3s-registries.yaml".path;
              systemd.services.k3s = {
                after = [ "sops-install-secrets.service" ];
                wants = [ "sops-install-secrets.service" ];
              };
            })
          ]
        ))
      ];

    homeManager.locale-cn =
      {
        config,
        lib,
        options,
        ...
      }:
      lib.mkMerge [
        {
          xdg.configFile."pip/pip.conf".text = ''
            [global]
            index-url = https://mirrors.tuna.tsinghua.edu.cn/pypi/web/simple
          '';
          xdg.configFile."containers/policy.json".text = builtins.toJSON containersPolicy;

          programs = {
            cargo = {
              enable = true;
              package = null;
              settings = {
                source = {
                  crates-io.replace-with = "rsproxy-sparse";
                  rsproxy.registry = "https://rsproxy.cn/crates.io-index";
                  rsproxy-sparse.registry = "sparse+https://rsproxy.cn/index/";
                };
                registries.rsproxy.index = "https://rsproxy.cn/crates.io-index";
                net.git-fetch-with-cli = true;
              };
            };

            go.env.GOPROXY = "https://goproxy.cn,direct";

            npm = {
              enable = true;
              package = null;
              settings.registry = "https://registry.npmmirror.com";
            };
          };

          nix.settings = {
            substituters = [
              "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store?priority=10"
              "https://mirrors.ustc.edu.cn/nix-channels/store?priority=20"
              "s3://nix-cache-miecho3l?endpoint=oss-cn-beijing.aliyuncs.com&addressing-style=virtual&profile=nix-cache-miecho3l&priority=30"
              "https://cache.nixos.org?priority=100"
            ];
          };
        }

        (withWorkstationSops config options (
          let
            prefix = config.sops.placeholder."configs/xuanyuan";
          in
          {
            sops.secrets."configs/xuanyuan" = { };

            sops.templates."rootless-buildkitd.toml" = {
              path = "${config.xdg.configHome}/buildkit/buildkitd.toml";
              content = buildkitRegistryConfig prefix;
            };

            sops.templates."rootless-containers-registries.conf" = {
              path = "${config.xdg.configHome}/containers/registries.conf";
              content = containersRegistryConfig prefix;
            };

            # Docker only supports a registry mirror for Docker Hub.
            sops.templates."rootless-docker-daemon.json" = {
              path = "${config.xdg.configHome}/docker/daemon.json";
              content = dockerRegistryConfig prefix;
            };
          }
        ))
      ];
  };
}
