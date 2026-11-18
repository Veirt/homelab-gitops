{ config, lib, ... }:
let
  cfg = config.homelab.services.ntfy;
in
{
  options.homelab.services.ntfy = {
    enable = lib.mkEnableOption "ntfy notification server";

    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Address on which ntfy listens.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 2586;
      description = "ntfy HTTP listen port.";
    };

    settings = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = { };
      description = "Additional ntfy server settings, kept in the host configuration.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.ntfy-sh = {
      enable = true;
      settings = cfg.settings // {
        listen-http = "${cfg.listenAddress}:${toString cfg.port}";
      };
    };
  };
}
