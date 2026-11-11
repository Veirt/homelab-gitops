{ config, lib, ... }:
let
  cfg = config.homelab.services.memos;
in
{
  options.homelab.services.memos = {
    enable = lib.mkEnableOption "the Memos Podman Quadlet";

    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Host address on which Memos publishes port 15230.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."containers/systemd/memos.container".text =
      builtins.replaceStrings [ "@LISTEN_ADDRESS@" ] [ cfg.listenAddress ]
        (builtins.readFile ./memos.container);
  };
}
