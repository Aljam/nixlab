{
  description = "Aljam's Unified Homelab Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  environment.systemPackages = with pkgs; [
    # Other packages...
    pkgs-stable.lutris 
  ];

  outputs = { self, nixpkgs, home-manager, disko, sops-nix, ... }@inputs:
  let
    system = "x86_64-linux";
    
    mkHost = { hostname, extraModules ? [] }: nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        ./hosts/${hostname}/configuration.nix
        ./modules/roles/common.nix
        ./users/aljam/nixos.nix
        sops-nix.nixosModules.sops
        
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
      
      r820 = mkHost { hostname = "r820"; };
      
      r730 = mkHost { 
        hostname = "r730";
        extraModules = [ disko.nixosModules.disko ]; 
      };
      
      r730xd = mkHost { 
        hostname = "r730xd";
        extraModules = [ disko.nixosModules.disko ];
      };
    };
  };
}
