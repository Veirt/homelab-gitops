{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homelab.services.grafana;
  dashboardDirectory =
    if cfg.dashboards == { } then
      null
    else
      pkgs.runCommand "grafana-dashboards" { } ''
        mkdir -p "$out"
        ${lib.concatStringsSep "\n" (
          lib.mapAttrsToList (relativePath: source: ''
            target="$out"/${lib.escapeShellArg relativePath}
            install -D -m 0444 "${source}" "$target"
          '') cfg.dashboards
        )}
      '';
  dashboardVolume = lib.optionalString (dashboardDirectory != null) (
    "Volume=/run/grafana-dashboards:/etc/grafana/dashboards:ro\n"
  );
  dashboardDependency = lib.optionalString (dashboardDirectory != null) ''
    Requires=grafana-dashboards.service
    After=grafana-dashboards.service
  '';
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
    # Keep the mounted directory stable; Grafana polls it while this service
    # refreshes the files from the immutable Nix bundle.
    systemd.services.grafana-dashboards = lib.mkIf (dashboardDirectory != null) {
      description = "Sync Grafana dashboards from the Nix store";
      wantedBy = [ "multi-user.target" ];
      before = [ "grafana.service" ];
      restartTriggers = [ dashboardDirectory ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        RuntimeDirectory = "grafana-dashboards";
        RuntimeDirectoryMode = "0755";
        RuntimeDirectoryPreserve = "yes";
        ExecStart = "${pkgs.rsync}/bin/rsync --archive --delete --chmod=Du=rwx,Dgo=rx,Fu=rw,Fgo=r ${dashboardDirectory}/ /run/grafana-dashboards/";
      };
    };

    environment.etc = {
      "containers/systemd/grafana.container".text =
        builtins.replaceStrings
          [ "@LISTEN_ADDRESS@" "@SERVER_DOMAIN@" "@ROOT_URL@" "@DASHBOARD_VOLUME@" "@DASHBOARD_DEPENDENCY@" ]
          [ cfg.listenAddress cfg.domain cfg.rootUrl dashboardVolume dashboardDependency ]
          (builtins.readFile ./grafana.container);

      "grafana/provisioning/datasources/homelab.yaml".text =
        builtins.replaceStrings
          [ "@PROMETHEUS_URL@" "@VICTORIA_METRICS_URL@" "@LOKI_URL@" ]
          [ cfg.prometheusUrl cfg.victoriaMetricsUrl cfg.lokiUrl ]
          (builtins.readFile ./datasources.yaml);

      "grafana/provisioning/dashboards/homelab.yaml".source = ./dashboards.yaml;
    }
    // lib.optionalAttrs (dashboardDirectory != null) {
      "grafana/dashboards".source = dashboardDirectory;
    };
  };
}
