{ pkgs, ... }:
{
  systemd.services.restic-backups-iris-gdrive.unitConfig.OnSuccess = "iris-restic-heartbeat.service";
  systemd.services.iris-restic-heartbeat = {
    description = "Report successful iris backup to Healthchecks";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.curl}/bin/curl --fail --silent --show-error --retry 3 --max-time 30 --output /dev/null --config /var/lib/restic/healthchecks-curl.conf";
    };
  };
}
