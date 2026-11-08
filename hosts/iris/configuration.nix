{ config, pkgs, lib, ... }:

{
  imports = [ ./iris-restic.nix ./iris-restic-maintenance.nix ./iris-restic-heartbeat.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "btrfs" ];

  hardware.enableRedistributableFirmware = true;
  environment.systemPackages = [ pkgs.git ];

  # Keep btrfs compression consistent across subvolumes.
  fileSystems = {
    "/".options          = [ "compress=zstd:1" "noatime" "discard=async" ];
    "/home".options      = [ "compress=zstd:1" "noatime" "discard=async" ];
    "/nix".options       = [ "compress=zstd:1" "noatime" "discard=async" ];
    "/var/log".options   = [ "compress=zstd:1" "noatime" "discard=async" ];
    "/var/lib".options   = [ "compress=zstd:1" "noatime" "discard=async" ];
    "/.snapshots".options = [ "compress=zstd:1" "noatime" "discard=async" ];
  };
  fileSystems."/var/log".neededForBoot = true;

  networking.hostName = "iris";
  time.timeZone = "Asia/Makassar";

  networking.firewall.enable = true;
  networking.nftables.enable = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    # Limit local builds for 3.6 GiB usable RAM.
    max-jobs = 2;
    cores = 2;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nix.optimise.automatic = true;

  # Revisit the zram percentage after a RAM upgrade.
  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  services.journald.extraConfig = ''
    SystemMaxUse=2G
  '';

  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };
  services.fstrim.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  users.users.veirt = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  security.sudo.wheelNeedsPassword = false;

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # Keep the metrics store off this memory-limited host.
  services.prometheus.exporters.node = {
    enable = true;
    port = 9100;
    openFirewall = true;
  };


  services.smartd.enable = true;
  hardware.rasdaemon.enable = true;

  services.fwupd.enable = true;

  system.stateVersion = "26.05";
}
