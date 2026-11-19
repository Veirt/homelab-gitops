{ config, lib, ... }:
let
  cfg = config.homelab.services.vesta;
in
{
  options.homelab.services.vesta = {
    enable = lib.mkEnableOption "the Vesta dashboard Quadlet";

    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Host address on which Vesta publishes its port.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8450;
      description = "LAN port published for Vesta.";
    };

    timeZone = lib.mkOption {
      type = lib.types.str;
      default = "UTC";
      description = "Time zone used by Vesta.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."containers/systemd/vesta.container".text =
      builtins.replaceStrings
        [ "@LISTEN_ADDRESS@" "@PORT@" "@TIME_ZONE@" ]
        [ cfg.listenAddress (toString cfg.port) cfg.timeZone ]
        (builtins.readFile ./vesta.container);

    homelab.persistence.paths = [ "/var/lib/vesta" ];
  };
}
