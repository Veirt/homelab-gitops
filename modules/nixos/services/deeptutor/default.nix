{ config, lib, ... }:
let
  cfg = config.homelab.services.deeptutor;
  quadlet = builtins.readFile ./deeptutor.container;
in
{
  options.homelab.services.deeptutor = {
    enable = lib.mkEnableOption "the DeepTutor Podman Quadlet";

    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Host address on which the DeepTutor frontend publishes port 3782.";
    };

  };

  config = lib.mkIf cfg.enable {
    environment.etc."containers/systemd/deeptutor.container".text =
      builtins.replaceStrings [ "@LISTEN_ADDRESS@" ] [ cfg.listenAddress ]
        quadlet;
  };
}
