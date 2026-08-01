{
  description = "Aljam's Unified Homelab Flake";

  modules = [
    ./modules/roles/common.nix
    ./users/aljam/nixos.nix
  ];

  inputs = {
    # Core OS (Change to nixos-23.11 if you prefer stable over unstable)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Add the community hardware repository
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Add sops-nix
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Disko (For Declarative ZFS formatting on the R730 & R730xd)
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, disko, ... }@inputs:
  let
    system = "x86_64-linux";
    
    # --- The Magic Helper Function ---
    # This function automatically injects inputs, passes Home Manager to your user,
    # and targets the correct configuration folder based solely on the hostname.
    mkHost = { hostname, extraModules ? [] }: nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; }; # Passes your inputs to all modules
      modules = [
        ./hosts/${hostname}/configuration.nix
        
        # Globally enforce Home Manager for the 'aljam' user across all hosts
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.users.aljam = import ./users/aljam/home.nix;
        }
      ] ++ extraModules;
    };

  in {
    nixosConfigurations = {
      # --- Personal Machines ---
      navi = mkHost { 
        hostname = "navi"; 
        extraModules = [
          { home-manager.users.aljam.imports = [ ./users/aljam/home-gui.nix ]; }
        ]; 
      };
      
      oryx = mkHost { 
        hostname = "oryx"; 
        extraModules = [
          { home-manager.users.aljam.imports = [ ./users/aljam/home-gui.nix ]; }
            inputs.nixos-hardware.nixosModules.system76
        ]; 
      };
      
      # --- Server Rack ---
      r820 = mkHost { hostname = "r820"; };

      # Servers requiring Disko for ZFS provisioning
      r730 = mkHost { 
        hostname = "r730"; 
        extraModules = [ disko.nixosModules.disko ]; 
      };
      
      r730xd = mkHost { 
        hostname = "r730xd";
        
        extraModules = [ 
          disko.nixosModules.disko
          inputs.sops-nix.nixosModules.sops  
        ]; 
      };
    };
  };
}
