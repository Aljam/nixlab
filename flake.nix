{
  description = "Unified NixOS Fleet Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }:
  let
    system = "x86_64-linux";
  in
  {
    nixosConfigurations = {
      navi = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/navi/configuration.nix
          home-manager.nixosModules.home-manager
        ];
      };

      oryx = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/oryx/configuration.nix
          home-manager.nixosModules.home-manager
        ];
      };

      r730 = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/r730/configuration.nix
        ];
      };

      r730xd = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/r730xd/configuration.nix
        ];
      };

      r820 = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/r820/configuration.nix
          ./hosts/r820/hardware-configuration.nix
          # ./modules/common-server.nix
        ];
      };
    };

    homeConfigurations.aljam = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${system};
      extraSpecialArgs = { inherit inputs; };
      modules = [
        ./users/aljam/home.nix
      ];
    };
  };
}
