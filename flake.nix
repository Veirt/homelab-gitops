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
      memosTestSystem = mkServiceTestSystem self.nixosModules.memos "memos" { };
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
      deeptutorTestSystem = mkServiceTestSystem self.nixosModules.deeptutor "deeptutor" { };
      publicServicesTestSystem = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          self.nixosModules.services
          {
            system.stateVersion = "26.05";
          }
        ];
      };
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
      memosTestUnit = pkgs.writeText "memos.container" (
        memosTestSystem.config.environment.etc."containers/systemd/memos.container".text
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
      deeptutorTestUnit = pkgs.writeText "deeptutor.container" (
        deeptutorTestSystem.config.environment.etc."containers/systemd/deeptutor.container".text
      );
      publicDeeptutorUnit = pkgs.writeText "public-deeptutor.container" (
        publicServicesTestSystem.config.environment.etc."containers/systemd/deeptutor.container".text
      );
      publicMemosUnit = pkgs.writeText "public-memos.container" (
        publicServicesTestSystem.config.environment.etc."containers/systemd/memos.container".text
      );
      publicPersistencePaths = pkgs.writeText "public-persistence-paths" (
        builtins.concatStringsSep "\n" publicServicesTestSystem.config.homelab.persistence.paths
      );
      publicTmpfilesRules = pkgs.writeText "public-tmpfiles-rules" (
        builtins.concatStringsSep "\n" publicServicesTestSystem.config.systemd.tmpfiles.rules
      );
    in
    {
      formatter.${system} = pkgs.nixfmt-tree;

      nixosModules.searxng = ./modules/nixos/services/searxng;
      nixosModules.grafana = ./modules/nixos/services/grafana;
      nixosModules.loki = ./modules/nixos/services/loki;
      nixosModules.memos = ./modules/nixos/services/memos;
      nixosModules.victoriaMetrics = ./modules/nixos/services/victoria-metrics;
      nixosModules.blackboxExporter = ./modules/nixos/services/blackbox-exporter;
      nixosModules.vaultwarden = ./modules/nixos/services/vaultwarden;
      nixosModules.deeptutor = ./modules/nixos/services/deeptutor;
      nixosModules.services = ./modules/nixos/services;

      checks.${system} = {
        searxng-quadlet = pkgs.runCommand "searxng-quadlet-check" { } ''
          grep --fixed-strings -- "Image=ghcr.io/searxng/searxng:2026.11.11-248b8ffc0" ${searxngTestUnit}
          grep --fixed-strings -- "Slice=apps.slice" ${searxngTestUnit}
          grep --fixed-strings -- "EnvironmentFile=/var/lib/searxng/searxng.env" ${searxngTestUnit}
          grep --fixed-strings -- "PublishPort=127.0.0.1:18888:8080" ${searxngTestUnit}
          grep --fixed-strings -- "Volume=/etc/searxng/settings.yml:/etc/searxng/settings.yml:ro" ${searxngTestUnit}
          grep --fixed-strings -- "Volume=/etc/searxng/uwsgi.ini:/etc/searxng/uwsgi.ini:ro" ${searxngTestUnit}
          grep --fixed-strings -- "Volume=/etc/searxng/searxng_serpapi:/etc/searxng/searxng_serpapi:ro" ${searxngTestUnit}
          touch "$out"
        '';

        grafana-quadlet = pkgs.runCommand "grafana-quadlet-check" { } ''
          grep --fixed-strings -- "Image=docker.io/grafana/grafana:13.0.11" ${grafanaTestUnit}
          grep --fixed-strings -- "Slice=apps.slice" ${grafanaTestUnit}
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
          grep --fixed-strings -- "Image=docker.io/grafana/loki:3.7.8" ${lokiTestUnit}
          grep --fixed-strings -- "Slice=apps.slice" ${lokiTestUnit}
          grep --fixed-strings -- "PublishPort=127.0.0.1:3100:3100" ${lokiTestUnit}
          grep --fixed-strings -- "retention_period: 336h" ${./modules/nixos/services/loki/config.yaml}
          grep --fixed-strings -- "retention_enabled: true" ${./modules/nixos/services/loki/config.yaml}
          touch "$out"
        '';

        memos-quadlet = pkgs.runCommand "memos-quadlet-check" { } ''
          grep --fixed-strings -- "Image=docker.io/neosmemo/memos:0.31.0" ${memosTestUnit}
          grep --fixed-strings -- "Slice=apps.slice" ${memosTestUnit}
          grep --fixed-strings -- "Volume=/var/lib/memos:/var/opt/memos" ${memosTestUnit}
          grep --fixed-strings -- "PublishPort=127.0.0.1:15230:5230" ${memosTestUnit}
          touch "$out"
        '';

        victoria-metrics-quadlet = pkgs.runCommand "victoria-metrics-quadlet-check" { } ''
          grep --fixed-strings -- "Image=docker.io/victoriametrics/victoria-metrics:v1.154.0" ${victoriaMetricsTestUnit}
          grep --fixed-strings -- "Slice=apps.slice" ${victoriaMetricsTestUnit}
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
          grep --fixed-strings -- "Image=ghcr.io/prometheus/blackbox-exporter:v0.29.1" ${blackboxExporterTestUnit}
          grep --fixed-strings -- "Slice=apps.slice" ${blackboxExporterTestUnit}
          grep --fixed-strings -- "Network=monitoring.network" ${blackboxExporterTestUnit}
          grep --fixed-strings -- "IP=10.89.0.10" ${blackboxExporterTestUnit}
          grep --fixed-strings -- "DNS=192.168.1.100" ${blackboxExporterTestUnit}
          grep --fixed-strings -- "Exec=--config.file=/etc/blackbox_exporter/blackbox.yml --web.listen-address=:9115" ${blackboxExporterTestUnit}
          grep --extended-regexp -- "^Volume=/nix/store/.*/modules/nixos/services/blackbox-exporter/blackbox.yml:/etc/blackbox_exporter/blackbox.yml:ro$" ${blackboxExporterTestUnit}
          if grep --quiet -- "PublishPort=" ${blackboxExporterTestUnit}; then exit 1; fi
          touch "$out"
        '';

        vaultwarden-quadlet = pkgs.runCommand "vaultwarden-quadlet-check" { } ''
          grep --fixed-strings -- "Image=docker.io/vaultwarden/server:1.37.4" ${vaultwardenTestUnit}
          grep --fixed-strings -- "Slice=apps.slice" ${vaultwardenTestUnit}
          grep --fixed-strings -- "Volume=/var/lib/vaultwarden:/data" ${vaultwardenTestUnit}
          grep --fixed-strings -- "PublishPort=127.0.0.1:8222:80" ${vaultwardenTestUnit}
          touch "$out"
        '';

        deeptutor-quadlet = pkgs.runCommand "deeptutor-quadlet-check" { } ''
          grep --fixed-strings -- "Image=ghcr.io/hkuds/deeptutor:1.7.2" ${deeptutorTestUnit}
          grep --fixed-strings -- "Slice=apps.slice" ${deeptutorTestUnit}
          grep --fixed-strings -- "PublishPort=127.0.0.1:3782:3782" ${deeptutorTestUnit}
          grep --fixed-strings -- "Volume=/var/lib/deeptutor/data:/app/data" ${deeptutorTestUnit}
          grep --fixed-strings -- "Volume=/var/lib/deeptutor/data/user/workspace:/workspace" ${deeptutorTestUnit}
          grep --fixed-strings -- "HealthCmd=curl -fsS http://localhost:8001/health/ready" ${deeptutorTestUnit}
          if grep --quiet -- "PublishPort=.*8001" ${deeptutorTestUnit}; then exit 1; fi
          touch "$out"
        '';

        services-profile = pkgs.runCommand "services-profile-check" { } ''
          grep --fixed-strings -- "Image=docker.io/neosmemo/memos:0.31.0" ${publicMemosUnit}
          grep --fixed-strings -- "PublishPort=127.0.0.1:15230:5230" ${publicMemosUnit}
          grep --fixed-strings -- "Image=ghcr.io/hkuds/deeptutor:1.7.2" ${publicDeeptutorUnit}
          grep --fixed-strings -- "PublishPort=127.0.0.1:3782:3782" ${publicDeeptutorUnit}
          grep --fixed-strings -- "ConditionPathExists=/var/lib/deeptutor/data/user/settings/system.json" ${./modules/nixos/services/default.nix}
          grep --fixed-strings -- "/var/lib/deeptutor" ${publicPersistencePaths}
          grep --fixed-strings -- "/var/lib/memos" ${publicPersistencePaths}
          grep --fixed-strings -- "d /var/lib/deeptutor 0700 root root -" ${publicTmpfilesRules}
          grep --fixed-strings -- "d /var/lib/memos 0750 10001 10001 -" ${publicTmpfilesRules}
          touch "$out"
        '';
      };
    };
}
