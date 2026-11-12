{ config, lib, ... }:
let
  cfg = config.homelab.services.silverbullet;
in
{
  options.homelab.services.silverbullet = {
    enable = lib.mkEnableOption "the SilverBullet Podman Quadlet";

    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Host address on which SilverBullet publishes port 3001.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."containers/systemd/silverbullet.container".text =
      builtins.replaceStrings [ "@LISTEN_ADDRESS@" ] [ cfg.listenAddress ]
        (builtins.readFile ./silverbullet.container);
  };
}
