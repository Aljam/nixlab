{ nixpkgs, ... }:

{
  description = "Nixlab - Multi-host homelab";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    sops-nix.url = "github:mic92/sops-nix";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, sops-nix, home-manager }:
    let
      # Network configuration - single source of truth
      networking = {
        fleet = {
          proxy.ip = "192.168.1.1";
        };
        subnets = {
          lan = "192.168.1.0/24";
          management = [ "127.0.0.0/8" ];
        };
      };

      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      inherit (import ./hosts) navi oryx r730 r730xd r820;
      inherit (import ./users) aljam;
    in
    {
      networking = networking;

      nixosConfigurations = {
        navi = navi { inherit nixpkgs self sops-nix home-manager networking; };
        oryx = oryx { inherit nixpkgs self sops-nix home-manager networking; };
        r730 = r730 { inherit nixpkgs self sops-nix home-manager networking; };
        r730xd = r730xd { inherit nixpkgs self sops-nix home-manager networking; };
        r820 = r820 { inherit nixpkgs self sops-nix home-manager networking; };
      };

      homeConfigurations = {
        "aljam@navi" = aljam { inherit nixpkgs self home-manager networking; };
      };

      devShells = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.mkShell {
          packages = [
            nixpkgs.legacyPackages.${system}.nil
            nixpkgs.legacyPackages.${system}.nixfmt-classic
            nixpkgs.legacyPackages.${system}.sops
          ];
        };
      });

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-classic);

      pre-commit = {
        check = forAllSystems (system: self.checks.${system}.pre-commit-check);
        config = import ./tests/pre-commit.nix { inherit nixpkgs; };
      };
    };
}
