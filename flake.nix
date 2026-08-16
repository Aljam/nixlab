{ nixpkgs, ... }:

{
  description = "Nixlab - Multi-host homelab";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # NixOS modules
    sops-nix.url = "github:mic92/sops-nix";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, sops-nix, home-manager }:
    let
      # Supported systems
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];

      # Helper function to generate attribute sets for each supported system
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Import NixOS configurations
      inherit (import ./hosts) navi oryx r730 r730xd r820;

      # Import user configurations
      inherit (import ./users) aljam;
    in
    {
      # NixOS configurations
      nixosConfigurations = {
        navi = navi { inherit nixpkgs self sops-nix home-manager; };
        oryx = oryx { inherit nixpkgs self sops-nix home-manager; };
        r730 = r730 { inherit nixpkgs self sops-nix home-manager; };
        r730xd = r730xd { inherit nixpkgs self sops-nix home-manager; };
        r820 = r820 { inherit nixpkgs self sops-nix home-manager; };
      };

      # User configurations
      homeConfigurations = {
        "aljam@navi" = aljam { inherit nixpkgs self home-manager; };
      };

      # Development and utility outputs
      devShells = forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.mkShell {
          packages = [
            nixpkgs.legacyPackages.${system}.nil
            nixpkgs.legacyPackages.${system}.nixfmt-classic
            nixpkgs.legacyPackages.${system}.sops
          ];
        };
      });

      # Formatter
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-classic);

      # Pre-commit checks
      pre-commit = {
        check = forAllSystems (system: self.checks.${system}.pre-commit-check);
        config = import ./tests/pre-commit.nix { inherit nixpkgs; };
      };
    };
}
