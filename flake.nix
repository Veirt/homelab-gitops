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

      grafanaTestDashboard = pkgs.writeText "grafana-test-dashboard.json" "{}";
      grafanaTestSystem = mkServiceTestSystem self.nixosModules.grafana "grafana" {
        dashboards."Infrastructure/iris-host-health.json" = grafanaTestDashboard;
      };
      lokiTestSystem = mkServiceTestSystem self.nixosModules.loki "loki" { };
      victoriaMetricsTestSystem =
        mkServiceTestSystem self.nixosModules.victoriaMetrics "victoriaMetrics"
          { };
      victoriaMetricsScrapeTestSystem =
        mkServiceTestSystem self.nixosModules.victoriaMetrics "victoriaMetrics"
          {
            network = "monitoring.network";
            scrapeConfigFile = pkgs.writeText "scrape.yml" "scrape_configs: []";
          };
      vaultwardenTestSystem = mkServiceTestSystem self.nixosModules.vaultwarden "vaultwarden" { };
      blackboxExporterTestSystem = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          self.nixosModules.blackboxExporter
          (
            { ... }:
            {
              homelab.services.blackboxExporter = {
                enable = true;
                network = "monitoring.network";
                ipAddress = "10.89.0.10";
                dnsServer = "192.168.1.100";
              };
              system.stateVersion = "26.05";
            }
          )
        ];
      };

      grafanaTestUnit = pkgs.writeText "grafana.container" (
        grafanaTestSystem.config.environment.etc."containers/systemd/grafana.container".text
      );
      grafanaTestProvider = pkgs.writeText "grafana-dashboards.yaml" (
        builtins.readFile
          grafanaTestSystem.config.environment.etc."grafana/provisioning/dashboards/homelab.yaml".source
      );
      grafanaTestDashboardRoot = grafanaTestSystem.config.environment.etc."grafana/dashboards".source;
      grafanaTestSyncUnit = grafanaTestSystem.config.systemd.units."grafana-dashboards.service".unit;
      lokiTestUnit = pkgs.writeText "loki.container" (
        lokiTestSystem.config.environment.etc."containers/systemd/loki.container".text
      );
      victoriaMetricsTestUnit = pkgs.writeText "victoria-metrics.container" (
        victoriaMetricsTestSystem.config.environment.etc."containers/systemd/victoria-metrics.container".text
      );
      victoriaMetricsScrapeTestUnit = pkgs.writeText "victoria-metrics-scrape.container" (
        victoriaMetricsScrapeTestSystem.config.environment.etc."containers/systemd/victoria-metrics.container".text
      );
      blackboxExporterTestUnit = pkgs.writeText "blackbox-exporter.container" (
        blackboxExporterTestSystem.config.environment.etc."containers/systemd/blackbox-exporter.container".text
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
      nixosModules.blackboxExporter = ./modules/nixos/services/blackbox-exporter;
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
          grep --fixed-strings -- "EnvironmentFile=/var/lib/grafana-admin.env" ${grafanaTestUnit}
          grep --fixed-strings -- "Volume=/run/grafana-dashboards:/etc/grafana/dashboards:ro" ${grafanaTestUnit}
          grep --fixed-strings -- "Wants=grafana-dashboards.service" ${grafanaTestUnit}
          grep --fixed-strings -- "After=grafana-dashboards.service" ${grafanaTestUnit}
          grep --fixed-strings -- "PublishPort=127.0.0.1:3000:3000" ${grafanaTestUnit}
          grep --fixed-strings -- "uid: bec75ss62w2rkc" ${./modules/nixos/services/grafana/datasources.yaml}
          grep --fixed-strings -- "path: /etc/grafana/dashboards" ${grafanaTestProvider}
          grep --fixed-strings -- "foldersFromFilesStructure: true" ${grafanaTestProvider}
          grep --fixed-strings -- "disableDeletion: false" ${grafanaTestProvider}
          grep --fixed-strings -- "RuntimeDirectory=grafana-dashboards" ${grafanaTestSyncUnit}/grafana-dashboards.service
          grep --fixed-strings -- "RemainAfterExit=true" ${grafanaTestSyncUnit}/grafana-dashboards.service
          grep --fixed-strings -- "RuntimeDirectoryPreserve=yes" ${grafanaTestSyncUnit}/grafana-dashboards.service
          grep --fixed-strings -- "--delete --chmod=Du=rwx,Dgo=rx,Fu=rw,Fgo=r" ${grafanaTestSyncUnit}/grafana-dashboards.service
          grep --fixed-strings -- "/run/grafana-dashboards/" ${grafanaTestSyncUnit}/grafana-dashboards.service
          trigger_file=$(sed --quiet --expression='s/^X-Restart-Triggers=//p' ${grafanaTestSyncUnit}/grafana-dashboards.service)
          test -n "$trigger_file"
          grep --fixed-strings -- "${grafanaTestDashboardRoot}" "$trigger_file"
          test -d ${grafanaTestDashboardRoot}
          test ! -L ${grafanaTestDashboardRoot}/Infrastructure/iris-host-health.json
          grep --fixed-strings -- "{}" ${grafanaTestDashboardRoot}/Infrastructure/iris-host-health.json
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
          grep --fixed-strings -- "Exec=-storageDataPath=/victoria-metrics-data -retentionPeriod=1y" ${victoriaMetricsTestUnit}
          grep --fixed-strings -- "PublishPort=127.0.0.1:8428:8428" ${victoriaMetricsTestUnit}
          if grep --quiet --extended-regexp -- "^(Network=|Exec=.*-promscrape\.config=|Volume=/nix/store/.*promscrape\.yml:)" ${victoriaMetricsTestUnit}; then exit 1; fi
          touch "$out"
        '';

        victoria-metrics-scrape-quadlet = pkgs.runCommand "victoria-metrics-scrape-quadlet-check" { } ''
          grep --fixed-strings -- "Network=monitoring.network" ${victoriaMetricsScrapeTestUnit}
          grep --fixed-strings -- "Exec=-storageDataPath=/victoria-metrics-data -retentionPeriod=1y -promscrape.config=/etc/victoria-metrics/promscrape.yml" ${victoriaMetricsScrapeTestUnit}
          grep --fixed-strings -- "/etc/victoria-metrics/promscrape.yml:ro" ${victoriaMetricsScrapeTestUnit}
          touch "$out"
        '';

        blackbox-exporter-quadlet = pkgs.runCommand "blackbox-exporter-quadlet-check" { } ''
          grep --fixed-strings -- "Image=ghcr.io/prometheus/blackbox-exporter@sha256:66eae352a79e6f677aeddd8c25a9bdb017586dc5fbd230f22329213d891f94bd" ${blackboxExporterTestUnit}
          grep --fixed-strings -- "Network=monitoring.network" ${blackboxExporterTestUnit}
          grep --fixed-strings -- "IP=10.89.0.10" ${blackboxExporterTestUnit}
          grep --fixed-strings -- "DNS=192.168.1.100" ${blackboxExporterTestUnit}
          grep --fixed-strings -- "Exec=--config.file=/etc/blackbox_exporter/blackbox.yml --web.listen-address=:9115" ${blackboxExporterTestUnit}
          grep --extended-regexp -- "^Volume=/nix/store/.*/modules/nixos/services/blackbox-exporter/blackbox.yml:/etc/blackbox_exporter/blackbox.yml:ro$" ${blackboxExporterTestUnit}
          if grep --quiet -- "PublishPort=" ${blackboxExporterTestUnit}; then exit 1; fi
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
