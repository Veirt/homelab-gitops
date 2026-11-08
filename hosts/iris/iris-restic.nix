{ pkgs, ... }:
{
  systemd.services.restic-backups-iris-gdrive.path = [ pkgs.rclone ];
  services.restic.backups.iris-gdrive = {
    repository = "rclone:gdrive:homelab-restic/iris";
    rcloneConfigFile = "/var/lib/restic/rclone.conf";
    passwordFile = "/var/lib/restic/password";
    paths = [ "/etc/nixos" ];
    initialize = true;
    timerConfig = { OnCalendar = "daily"; Persistent = true; RandomizedDelaySec = "30m"; };
  };
}
