{
  description = "Homelab NixOS configurations";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/c56a87d8e41ce69bd2af57eb35dcc117a9dfca33";

  outputs =
    {
      self,
      nixpkgs,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      searxngTestSystem = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          self.nixosModules.searxng
          (
            { ... }:
            {
              homelab.services.searxng = {
                enable = true;
                listenAddress = "127.0.0.1";
              };
              system.stateVersion = "26.05";
            }
          )
        ];
      };

      searxngTestUnit = pkgs.writeText "searxng.container" (
        searxngTestSystem.config.environment.etc."containers/systemd/searxng.container".text
      );
    in
    {
      formatter.${system} = pkgs.nixfmt-tree;

      nixosModules.iris-base = ./hosts/iris/configuration.nix;
      nixosModules.searxng = ./services/searxng;

      checks.${system}.searxng-quadlet = pkgs.runCommand "searxng-quadlet-check" { } ''
        grep --fixed-strings -- "Image=ghcr.io/searxng/searxng@sha256:77b6ec55d5176fc47cfe91df5e182393133305358741d0c80ebbeec75ac39f99" ${searxngTestUnit}
        grep --fixed-strings -- "EnvironmentFile=/var/lib/searxng/searxng.env" ${searxngTestUnit}
        grep --fixed-strings -- "PublishPort=127.0.0.1:18888:8080" ${searxngTestUnit}
        grep --fixed-strings -- "Volume=/etc/searxng/settings.yml:/etc/searxng/settings.yml:ro" ${searxngTestUnit}
        grep --fixed-strings -- "Volume=/etc/searxng/uwsgi.ini:/etc/searxng/uwsgi.ini:ro" ${searxngTestUnit}
        grep --fixed-strings -- "Volume=/etc/searxng/searxng_serpapi:/etc/searxng/searxng_serpapi:ro" ${searxngTestUnit}
        touch "$out"
      '';
    };
}
