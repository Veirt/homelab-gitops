{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homelab.services.miniserve;
in
{
  options.homelab.services.miniserve = {
    enable = lib.mkEnableOption "the read-only Miniserve file server";

    bindAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Address on which Miniserve listens.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8082;
      description = "Miniserve listen port.";
    };

    shareDirectory = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/miniserve/share";
      description = "Directory served read-only by Miniserve.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.miniserve = { };
    users.users.miniserve = {
      isSystemUser = true;
      group = "miniserve";
      home = "/var/lib/miniserve";
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/miniserve 0700 miniserve miniserve -"
      "d ${cfg.shareDirectory} 0700 miniserve miniserve -"
    ];

    systemd.services.miniserve = {
      description = "Loopback-only read-only Miniserve";
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${pkgs.miniserve}/bin/miniserve --interfaces ${cfg.bindAddress} --port ${toString cfg.port} ${cfg.shareDirectory}";
        User = "miniserve";
        Group = "miniserve";
        UMask = "0077";
        Slice = "apps.slice";
        StateDirectory = "miniserve";
        StateDirectoryMode = "0700";
        Restart = "on-failure";
        RestartSec = "5s";
        MemoryMax = "64M";

        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        ReadOnlyPaths = [ cfg.shareDirectory ];
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
          "AF_INET6"
        ];
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        LockPersonality = true;
        CapabilityBoundingSet = "";
        AmbientCapabilities = "";
      };
    };

    homelab.persistence.paths = [ "/var/lib/miniserve" ];
  };
}
