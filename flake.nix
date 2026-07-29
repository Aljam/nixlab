{
  description = "Unified NixOS Fleet Flake";

    inputs = {
      nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
      disko.url = "github:nix-community/disko";
      disko.inputs.nixpkgs.follows = "nixpkgs";
      home-manager = {
        url = "github:nix-community/home-manager/";
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
          inputs.disko.nixosModules.disko
          ./hosts/r730/hardware-configuration.nix
          ./hosts/r730/disko-config.nix
          ./hosts/r730/configuration.nix
        ];
      };

      r730xd = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          inputs.disko.nixosModules.disko
          ./hosts/r730xd/hardware-configuration.nix
          ./hosts/r730xd/disko-config.nix
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

    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      substituters = [ "https://cache.nixos-cuda.org" ];
      trusted-public-keys = [ "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M=" ];
    };

    homeConfigurations.aljam = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      extraSpecialArgs = { inherit inputs; };
      modules = [
        ./users/aljam/home.nix
      ];
    };
  };
}
