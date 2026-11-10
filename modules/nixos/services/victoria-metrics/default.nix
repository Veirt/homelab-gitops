{ config, lib, ... }:
let
  cfg = config.homelab.services.victoriaMetrics;
  execArgs = [
    "-storageDataPath=/victoria-metrics-data"
    "-retentionPeriod=1y"
  ]
  ++ lib.optional (
    cfg.scrapeConfigFile != null
  ) "-promscrape.config=/etc/victoria-metrics/promscrape.yml";
in
{
  options.homelab.services.victoriaMetrics = {
    enable = lib.mkEnableOption "the VictoriaMetrics Podman Quadlet";

    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Host address on which VictoriaMetrics publishes port 8428.";
    };

    network = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Optional Podman Quadlet network unit for VictoriaMetrics.";
    };

    scrapeConfigFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Optional Prometheus-compatible scrape configuration file.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."containers/systemd/victoria-metrics.container".text =
      builtins.replaceStrings
        [ "@LISTEN_ADDRESS@" "@NETWORK@" "@EXEC_ARGS@" "@SCRAPE_CONFIG_VOLUME@" ]
        [
          cfg.listenAddress
          (lib.optionalString (cfg.network != null) "Network=${cfg.network}\n")
          (lib.concatStringsSep " " execArgs)
          (lib.optionalString (
            cfg.scrapeConfigFile != null
          ) "Volume=${toString cfg.scrapeConfigFile}:/etc/victoria-metrics/promscrape.yml:ro\n")
        ]
        (builtins.readFile ./victoria-metrics.container);
  };
}
