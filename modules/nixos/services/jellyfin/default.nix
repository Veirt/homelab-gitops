{ config, lib, ... }:
let
  cfg = config.homelab.services.jellyfin;
in
{
  options.homelab.services.jellyfin = {
    enable = lib.mkEnableOption "Jellyfin media server";

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/jellyfin";
      description = "Jellyfin data directory.";
    };

    configDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/jellyfin/config";
      description = "Jellyfin configuration directory.";
    };

    cacheDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/cache/jellyfin";
      description = "Jellyfin cache directory.";
    };

    logDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/log/jellyfin";
      description = "Jellyfin log directory.";
    };

    mediaMounts = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Read-only bind mounts made available to Jellyfin.";
    };

    requiresMountsFor = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Host mount paths required before Jellyfin starts.";
    };

    user = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Optional host service user override.";
    };

    group = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Optional host service group override.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.jellyfin = {
      enable = true;
      dataDir = cfg.dataDir;
      configDir = cfg.configDir;
      cacheDir = cfg.cacheDir;
      logDir = cfg.logDir;
      openFirewall = false;
    };

    systemd.services.jellyfin = {
      unitConfig.RequiresMountsFor = cfg.requiresMountsFor;
      serviceConfig = {
        Slice = "apps.slice";
        BindReadOnlyPaths = cfg.mediaMounts;
      }
      // lib.optionalAttrs (cfg.user != null) { User = lib.mkForce cfg.user; }
      // lib.optionalAttrs (cfg.group != null) { Group = lib.mkForce cfg.group; };
    };
  };
}
