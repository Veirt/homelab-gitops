{ pkgs, ... }:
{
  systemd.services.iris-restic-retention = {
    description = "Apply retention to iris Google Drive restic repository";
    path = [ pkgs.rclone ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/run/current-system/sw/bin/restic-iris-gdrive forget --prune --keep-daily 7 --keep-weekly 4 --keep-monthly 6";
    };
  };
  systemd.timers.iris-restic-retention = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "monthly";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
  };
}
