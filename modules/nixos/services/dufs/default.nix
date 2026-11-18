{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.homelab.services.dufs;
in
{
  options.homelab.services.dufs = {
    enable = lib.mkEnableOption "the read-only Dufs file server";

    bindAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Address on which Dufs listens.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 5000;
      description = "Dufs listen port.";
    };

    directory = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/dufs";
      description = "Directory served read-only by Dufs.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "nobody";
      description = "System user running Dufs.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "nobody";
      description = "System group running Dufs.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.dufs = {
      description = "Read-only Dufs file server";
      wantedBy = [ "multi-user.target" ];
      unitConfig.RequiresMountsFor = [ cfg.directory ];

      serviceConfig = {
        ExecStart = "${pkgs.dufs}/bin/dufs --bind ${cfg.bindAddress} --port ${toString cfg.port} ${cfg.directory}";
        User = cfg.user;
        Group = cfg.group;
        UMask = "0027";
        Slice = "apps.slice";
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
        ReadOnlyPaths = [ cfg.directory ];
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
  };
}
