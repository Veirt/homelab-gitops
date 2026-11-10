{ config, lib, ... }:
let
  cfg = config.homelab.services.victoriaMetrics;
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
        [ "@LISTEN_ADDRESS@" "@NETWORK@" "@SCRAPE_CONFIG@" ]
        [
          cfg.listenAddress
          (lib.optionalString (cfg.network != null) "Network=${cfg.network}\n")
          (lib.optionalString (cfg.scrapeConfigFile != null) ''
            Exec=-promscrape.config=/etc/victoria-metrics/promscrape.yml
            Volume=${toString cfg.scrapeConfigFile}:/etc/victoria-metrics/promscrape.yml:ro
          '')
        ]
        (builtins.readFile ./victoria-metrics.container);
  };
}
