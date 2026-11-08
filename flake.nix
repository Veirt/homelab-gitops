{
  description = "Homelab NixOS configurations";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/c56a87d8e41ce69bd2af57eb35dcc117a9dfca33";
  inputs.private = {
    url = "git+ssh://git@github.com/veirt/homelab-gitops-private?ref=master";
    flake = false;
  };
  outputs = { nixpkgs, private, ... }: {
    nixosConfigurations.iris = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./hosts/iris/configuration.nix (private + "/hosts/iris/workloads.nix") (private + "/hosts/iris/hardware-configuration.nix") (private + "/hosts/iris/identity.nix") ];
    };
  };
}
