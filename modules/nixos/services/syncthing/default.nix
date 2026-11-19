{ config, lib, ... }:
let
  cfg = config.homelab.services.syncthing;
in
{
  options.homelab.services.syncthing = {
    enable = lib.mkEnableOption "Syncthing file synchronization";

    user = lib.mkOption {
      type = lib.types.str;
      default = "syncthing";
      description = "System user running Syncthing.";
    };

    group = lib.mkOption {
      type = lib.types.str;
      default = "syncthing";
      description = "System group running Syncthing.";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/syncthing";
      description = "Syncthing data directory.";
    };

    configDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/syncthing/.config/syncthing";
      description = "Syncthing configuration directory.";
    };

    guiAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1:8384";
      description = "Address and port for the Syncthing web GUI.";
    };

    openDefaultPorts = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether Syncthing should open its default discovery and sync ports.";
    };

    overrideDevices = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether declarative device definitions replace runtime state.";
    };

    overrideFolders = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether declarative folder definitions replace runtime state.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      inherit (cfg)
        user
        group
        dataDir
        configDir
        guiAddress
        openDefaultPorts
        overrideDevices
        overrideFolders
        ;
    };

    systemd.services.syncthing.serviceConfig.Slice = "apps.slice";

    # This includes Syncthing's identity/config and its local index. Folder
    # contents outside dataDir remain the responsibility of their storage.
    homelab.persistence.paths = [ cfg.dataDir ];
  };
}
