{
  description = "Reusable homelab NixOS modules";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/c56a87d8e41ce69bd2af57eb35dcc117a9dfca33";

  outputs =
    {
      self,
      nixpkgs,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      searxngTestSystem = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          self.nixosModules.searxng
          (
            { ... }:
            {
              homelab.services.searxng = {
                enable = true;
                listenAddress = "127.0.0.1";
              };
              system.stateVersion = "26.05";
            }
          )
        ];
      };

      searxngTestUnit = pkgs.writeText "searxng.container" (
        searxngTestSystem.config.environment.etc."containers/systemd/searxng.container".text
      );

      mkServiceTestSystem =
        module: service: settings:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            module
            (
              { ... }:
              {
                homelab.services.${service} = {
                  enable = true;
                  listenAddress = "127.0.0.1";
                }
                // settings;
                system.stateVersion = "26.05";
              }
            )
          ];
        };

      grafanaTestSystem = mkServiceTestSystem self.nixosModules.grafana "grafana" { };
      lokiTestSystem = mkServiceTestSystem self.nixosModules.loki "loki" { };
      victoriaMetricsTestSystem =
        mkServiceTestSystem self.nixosModules.victoriaMetrics "victoriaMetrics"
          { };
      vaultwardenTestSystem = mkServiceTestSystem self.nixosModules.vaultwarden "vaultwarden" { };

      grafanaTestUnit = pkgs.writeText "grafana.container" (
        grafanaTestSystem.config.environment.etc."containers/systemd/grafana.container".text
      );
      lokiTestUnit = pkgs.writeText "loki.container" (
        lokiTestSystem.config.environment.etc."containers/systemd/loki.container".text
      );
      victoriaMetricsTestUnit = pkgs.writeText "victoria-metrics.container" (
        victoriaMetricsTestSystem.config.environment.etc."containers/systemd/victoria-metrics.container".text
      );
      vaultwardenTestUnit = pkgs.writeText "vaultwarden.container" (
        vaultwardenTestSystem.config.environment.etc."containers/systemd/vaultwarden.container".text
      );
    in
    {
      formatter.${system} = pkgs.nixfmt-tree;

      nixosModules.searxng = ./modules/nixos/services/searxng;
      nixosModules.grafana = ./modules/nixos/services/grafana;
      nixosModules.loki = ./modules/nixos/services/loki;
      nixosModules.victoriaMetrics = ./modules/nixos/services/victoria-metrics;
      nixosModules.vaultwarden = ./modules/nixos/services/vaultwarden;

      checks.${system} = {
        searxng-quadlet = pkgs.runCommand "searxng-quadlet-check" { } ''
          grep --fixed-strings -- "Image=ghcr.io/searxng/searxng@sha256:77b6ec55d5176fc47cfe91df5e182393133305358741d0c80ebbeec75ac39f99" ${searxngTestUnit}
          grep --fixed-strings -- "EnvironmentFile=/var/lib/searxng/searxng.env" ${searxngTestUnit}
          grep --fixed-strings -- "PublishPort=127.0.0.1:18888:8080" ${searxngTestUnit}
          grep --fixed-strings -- "Volume=/etc/searxng/settings.yml:/etc/searxng/settings.yml:ro" ${searxngTestUnit}
          grep --fixed-strings -- "Volume=/etc/searxng/uwsgi.ini:/etc/searxng/uwsgi.ini:ro" ${searxngTestUnit}
          grep --fixed-strings -- "Volume=/etc/searxng/searxng_serpapi:/etc/searxng/searxng_serpapi:ro" ${searxngTestUnit}
          touch "$out"
        '';

        grafana-quadlet = pkgs.runCommand "grafana-quadlet-check" { } ''
          grep --fixed-strings -- "Image=docker.io/grafana/grafana@sha256:2abd2114bb65e4d6f0614206b7c882c1e7c6a992827ba08396aa5afc23ca07f5" ${grafanaTestUnit}
          grep --fixed-strings -- "EnvironmentFile=/var/lib/grafana/grafana.env" ${grafanaTestUnit}
          grep --fixed-strings -- "PublishPort=127.0.0.1:3000:3000" ${grafanaTestUnit}
          grep --fixed-strings -- "uid: bec75ss62w2rkc" ${./modules/nixos/services/grafana/datasources.yaml}
          touch "$out"
        '';

        loki-quadlet = pkgs.runCommand "loki-quadlet-check" { } ''
          grep --fixed-strings -- "Image=docker.io/grafana/loki@sha256:1107dd5274e0ada47e42472b7a7e71f3b2a2fe878878108f3e2f9e51528f0193" ${lokiTestUnit}
          grep --fixed-strings -- "PublishPort=127.0.0.1:3100:3100" ${lokiTestUnit}
          grep --fixed-strings -- "retention_period: 336h" ${./modules/nixos/services/loki/config.yaml}
          grep --fixed-strings -- "retention_enabled: true" ${./modules/nixos/services/loki/config.yaml}
          touch "$out"
        '';

        victoria-metrics-quadlet = pkgs.runCommand "victoria-metrics-quadlet-check" { } ''
          grep --fixed-strings -- "Image=docker.io/victoriametrics/victoria-metrics@sha256:03d6215d8d860656880719f757beb8a43a3b9eeafccc080de7f304f4ab389ba3" ${victoriaMetricsTestUnit}
          grep --fixed-strings -- "Exec=-retentionPeriod=1y" ${victoriaMetricsTestUnit}
          grep --fixed-strings -- "PublishPort=127.0.0.1:8428:8428" ${victoriaMetricsTestUnit}
          touch "$out"
        '';

        vaultwarden-quadlet = pkgs.runCommand "vaultwarden-quadlet-check" { } ''
          grep --fixed-strings -- "Image=docker.io/vaultwarden/server@sha256:19ea2b669945d842dadc3d500f2d6a795866a003330f59a47b9634658bae98bb" ${vaultwardenTestUnit}
          grep --fixed-strings -- "Volume=/var/lib/vaultwarden:/data" ${vaultwardenTestUnit}
          grep --fixed-strings -- "PublishPort=127.0.0.1:8222:80" ${vaultwardenTestUnit}
          touch "$out"
        '';
      };
    };
}
