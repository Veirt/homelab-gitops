{ config, lib, ... }:
let
  cfg = config.homelab.services.vaultwarden;
in
{
  options.homelab.services.vaultwarden = {
    enable = lib.mkEnableOption "the Vaultwarden Podman Quadlet";

    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Host address on which Vaultwarden publishes port 8222.";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      default = "https://localhost";
      description = "External HTTPS URL used by Vaultwarden.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."containers/systemd/vaultwarden.container".text =
      builtins.replaceStrings [ "@LISTEN_ADDRESS@" "@DOMAIN@" ] [ cfg.listenAddress cfg.domain ]
        (builtins.readFile ./vaultwarden.container);
  };
}
