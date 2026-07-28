{
  description = "Unified NixOS Fleet Flake (Navi, Oryx, and PowerEdge Rack)";

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
      
      # ------------------------------------
      # PERSONAL MACHINES
      # ------------------------------------
      
      # Primary Desktop
      navi = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/navi/configuration.nix
          ./hosts/navi/hardware-configuration.nix
          home-manager.nixosModules.home-manager
          { nixpkgs.config.allowUnfree = true; }
          # ./modules/common.nix 
        ];
      };

      # System76 Laptop
      oryx = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/oryx/configuration.nix
          ./hosts/oryx/hardware-configuration.nix
          home-manager.nixosModules.home-manager
          { nixpkgs.config.allowUnfree = true; }
          # ./modules/common.nix
        ];
      };

      # ------------------------------------
      # SERVER RACK (HEADLESS)
      # ------------------------------------

      # Dell PowerEdge R730 (VMs & Databases)
      r730 = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/r730/configuration.nix
          ./hosts/r730/hardware-configuration.nix
          # ./modules/common-server.nix
        ];
      };

      # Dell PowerEdge R730xd (Massive Media Pool)
      r730xd = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/r730xd/configuration.nix
          ./hosts/r730xd/hardware-configuration.nix
          # ./modules/common-server.nix
        ];
      };

      # Dell PowerEdge R820 (Currently Sidelined)
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

    # Shared Home Manager Configuration
    homeConfigurations.aljam = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${system};
      extraSpecialArgs = { inherit inputs; };
      # modules = [ ./home.nix ];
    };
  };
}
