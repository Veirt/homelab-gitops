{ lib, ... }:
{
  imports = [
    ./blackbox-exporter
    ./deeptutor
    ./grafana
    ./loki
    ./memos
    ./searxng
    ./silverbullet
    ./vaultwarden
    ./victoria-metrics
  ];

  options.homelab.persistence.paths = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    description = "Persistent application paths to include in the host backup.";
  };

  config = {
    # Public app selection lives with the public service definitions. The
    # private host imports this services module once, not each app individually.
    homelab.services = {
      blackboxExporter.enable = true;
      deeptutor = {
        enable = true;
        # Restored auth is disabled, so keep the UI local until auth/ingress are
        # deliberately configured.
        listenAddress = "127.0.0.1";
      };
      grafana.enable = true;
      loki.enable = true;
      memos.enable = true;
      searxng.enable = true;
      vaultwarden.enable = true;
      victoriaMetrics.enable = true;
    };

    networking.firewall.allowedTCPPorts = [
      3000 # Grafana
      3100 # Loki
      8222 # Vaultwarden
      8428 # VictoriaMetrics
      15230 # Memos
      18888 # SearXNG
    ];

    systemd.tmpfiles.rules = [
      "d /var/lib/deeptutor 0700 root root -"
      "d /var/lib/grafana 0750 472 0 -"
      "f /var/lib/grafana-admin.env 0600 root root -"
      "d /var/lib/loki 0700 10001 10001 -"
      "d /var/lib/memos 0750 10001 10001 -"
      "d /var/lib/searxng 0700 root root -"
      "z /var/lib/searxng/searxng.env 0600 root root -"
      "d /var/lib/vaultwarden 0700 root root -"
      "d /var/lib/victoria-metrics 0700 root root -"
    ];

    environment.etc."containers/systemd/deeptutor.container.d/restore-data.conf".text = ''
      [Unit]
      ConditionPathExists=/var/lib/deeptutor/data/user/settings/system.json
    '';

    homelab.persistence.paths = [
      "/var/lib/deeptutor"
      "/var/lib/grafana"
      "/var/lib/grafana-admin.env"
      "/var/lib/loki"
      "/var/lib/memos"
      "/var/lib/searxng"
      "/var/lib/vaultwarden"
      "/var/lib/victoria-metrics"
    ];
  };
}
