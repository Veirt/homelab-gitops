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
  };

  config = lib.mkIf cfg.enable {
    environment.etc."containers/systemd/victoria-metrics.container".text =
      builtins.replaceStrings [ "@LISTEN_ADDRESS@" ] [ cfg.listenAddress ]
        (builtins.readFile ./victoria-metrics.container);
  };
}
