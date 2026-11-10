{ config, lib, ... }:
let
  cfg = config.homelab.services.searxng;
in
{
  options.homelab.services.searxng = {
    enable = lib.mkEnableOption "the SearXNG Podman Quadlet";

    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Host address on which the SearXNG container publishes port 18888.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."containers/systemd/searxng.container".text =
      builtins.replaceStrings [ "@LISTEN_ADDRESS@" ] [ cfg.listenAddress ]
        (builtins.readFile ./searxng.container);
    environment.etc."searxng/settings.yml".source = ./settings.yml;
    environment.etc."searxng/uwsgi.ini".source = ./uwsgi.ini;
    environment.etc."searxng/searxng_serpapi".source = ./searxng_serpapi;
  };
}
