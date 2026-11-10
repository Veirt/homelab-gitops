{ config, lib, ... }:
let
  cfg = config.homelab.services.blackboxExporter;
in
{
  options.homelab.services.blackboxExporter = {
    enable = lib.mkEnableOption "the Blackbox Exporter Podman Quadlet";

    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = ":9115";
      description = "Address on which Blackbox Exporter listens inside its container.";
    };

    network = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Optional Podman Quadlet network unit for Blackbox Exporter.";
    };

    configFile = lib.mkOption {
      type = lib.types.path;
      default = ./blackbox.yml;
      description = "Blackbox Exporter module configuration file.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."containers/systemd/blackbox-exporter.container".text =
      builtins.replaceStrings
        [ "@LISTEN_ADDRESS@" "@NETWORK@" "@CONFIG_FILE@" ]
        [
          cfg.listenAddress
          (lib.optionalString (cfg.network != null) "Network=${cfg.network}\n")
          (toString cfg.configFile)
        ]
        (builtins.readFile ./blackbox-exporter.container);
  };
}
