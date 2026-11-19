{ config, lib, ... }:
let
  cfg = config.homelab.services.wakapi;
in
{
  options.homelab.services.wakapi = {
    enable = lib.mkEnableOption "the Wakapi Podman Quadlet";

    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Host address on which the Wakapi container publishes its port.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 13000;
      description = "LAN port published for Wakapi.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."containers/systemd/wakapi.container".text =
      builtins.replaceStrings [ "@LISTEN_ADDRESS@" "@PORT@" ] [ cfg.listenAddress (toString cfg.port) ]
        (builtins.readFile ./wakapi.container);

    homelab.persistence.paths = [ "/var/lib/wakapi" ];
  };
}
