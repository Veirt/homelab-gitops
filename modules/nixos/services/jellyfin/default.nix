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

    mediaReadOnly = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether the mediaMounts are bind-mounted read-only
        (BindReadOnlyPaths) or read-write (BindPaths). Read-write lets
        Jellyfin rename, delete, and write metadata inside the media tree.
      '';
    };

    requiresMountsFor = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Host mount paths required before Jellyfin starts.";
    };

    user = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Optional NixOS Jellyfin service user.";
    };

    group = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Optional NixOS Jellyfin service group.";
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
    }
    // lib.optionalAttrs (cfg.user != null) { user = cfg.user; }
    // lib.optionalAttrs (cfg.group != null) { group = cfg.group; };

    systemd.services.jellyfin = {
      unitConfig.RequiresMountsFor = cfg.requiresMountsFor;
      serviceConfig = {
        Slice = "apps.slice";
        BindReadOnlyPaths = lib.mkIf cfg.mediaReadOnly cfg.mediaMounts;
        BindPaths = lib.mkIf (!cfg.mediaReadOnly) cfg.mediaMounts;
      };
    };

    # Preserve the library database, users, and service configuration. The
    # separately configured cache directory is regenerable and is not included.
    homelab.persistence.paths = lib.unique [
      cfg.dataDir
      cfg.configDir
    ];
  };
}
