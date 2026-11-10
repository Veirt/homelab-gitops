{ config, lib, ... }:
let
  cfg = config.homelab.services.grafana;
  dashboardVolume =
    if cfg.dashboards == { } then "" else "Volume=/etc/grafana/dashboards:/etc/grafana/dashboards:ro\n";
  dashboardEtc = lib.mapAttrs' (relativePath: source: {
    name = "grafana/dashboards/${relativePath}";
    value = { inherit source; };
  }) cfg.dashboards;
in
{
  options.homelab.services.grafana = {
    enable = lib.mkEnableOption "the Grafana Podman Quadlet";

    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Host address on which Grafana publishes port 3000.";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      default = "localhost";
      description = "External hostname configured in Grafana.";
    };

    rootUrl = lib.mkOption {
      type = lib.types.str;
      default = "http://localhost:3000/";
      description = "External URL configured in Grafana.";
    };

    prometheusUrl = lib.mkOption {
      type = lib.types.str;
      default = "http://127.0.0.1:9090";
      description = "URL for the Prometheus-compatible scrape service.";
    };

    victoriaMetricsUrl = lib.mkOption {
      type = lib.types.str;
      default = "http://127.0.0.1:8428";
      description = "URL for VictoriaMetrics.";
    };

    lokiUrl = lib.mkOption {
      type = lib.types.str;
      default = "http://127.0.0.1:3100";
      description = "URL for Loki.";
    };

    dashboards = lib.mkOption {
      type = lib.types.attrsOf lib.types.path;
      default = { };
      description = ''
        Dashboard JSON files keyed by paths relative to the provisioned dashboard
        root. Directory names become Grafana folders.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc = {
      "containers/systemd/grafana.container".text =
        builtins.replaceStrings
          [ "@LISTEN_ADDRESS@" "@SERVER_DOMAIN@" "@ROOT_URL@" "@DASHBOARD_VOLUME@" ]
          [ cfg.listenAddress cfg.domain cfg.rootUrl dashboardVolume ]
          (builtins.readFile ./grafana.container);

      "grafana/provisioning/datasources/homelab.yaml".text =
        builtins.replaceStrings
          [ "@PROMETHEUS_URL@" "@VICTORIA_METRICS_URL@" "@LOKI_URL@" ]
          [ cfg.prometheusUrl cfg.victoriaMetricsUrl cfg.lokiUrl ]
          (builtins.readFile ./datasources.yaml);

      "grafana/provisioning/dashboards/homelab.yaml".source = ./dashboards.yaml;
    }
    // dashboardEtc;
  };
}
