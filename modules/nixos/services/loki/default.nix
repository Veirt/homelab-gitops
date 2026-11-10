{ config, lib, ... }:
let
  cfg = config.homelab.services.loki;
in
{
  options.homelab.services.loki = {
    enable = lib.mkEnableOption "the Loki Podman Quadlet";

    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Host address on which Loki publishes port 3100.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."containers/systemd/loki.container".text =
      builtins.replaceStrings [ "@LISTEN_ADDRESS@" ] [ cfg.listenAddress ]
        (builtins.readFile ./loki.container);
    environment.etc."loki/config.yaml".source = ./config.yaml;
  };
}
