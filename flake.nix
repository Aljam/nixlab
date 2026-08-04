{
  description = "Aljam's Unified Homelab Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
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
    
    nix-flatpak.url = "github:gmodena/nix-flatpak";
  };

  outputs = { self, nixpkgs, nixpkgs-stable, home-manager, disko, sops-nix, mailserver, ... }@inputs:
  let
    system = "x86_64-linux";
    
    pkgs-stable = import nixpkgs-stable {
      inherit system;
    };

    domains = {
      primary    = "derezzed.info";       # Media server & stats
      fuwa       = "fuwa.space";
      cybal      = "cybal.org";
      netrunner  = "netrunner.dev";
      
      glow_net   = "glowrunner.network";
      glow_dev   = "glowrunner.dev";
      glow_xyz   = "glowrunner.xyz";
    };
    
    mkHost = { hostname, extraModules ? [] }: nixpkgs.lib.nixosSystem {
      inherit system;
      
      specialArgs = { inherit inputs pkgs-stable hostname domains; }; 
      
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
          
          # Allows Home Manager to evaluate unfree packages like Steam & Discord
          home-manager.sharedModules = [{
            nixpkgs.config.allowUnfree = true;
          }];
          
          home-manager.extraSpecialArgs = { inherit inputs pkgs-stable domains; };
        }
      ] ++ extraModules;
    };

    desktop = { home-manager.users.aljam.imports = [ ./users/aljam/home-gui.nix ]; };
    serverDisko = disko.nixosModules.disko;
    flatpakModule = inputs.nix-flatpak.nixosModules.nix-flatpak;

  in {
    nixosConfigurations = {
      
      navi = mkHost { 
        hostname = "navi";
        extraModules = [ desktop flatpakModule ]; 
      };
      
      oryx = mkHost { 
        hostname = "oryx";
        extraModules = [ 
          desktop 
          flatpakModule 
          inputs.nix-hardware.nixosModules.system76 
        ];
      };
      
      r820 = mkHost { 
        hostname = "r820"; 
      };
      
      r730 = mkHost { 
        hostname = "r730";
        extraModules = [ serverDisko ]; 
      };
      
      r730xd = mkHost { 
        hostname = "r730xd";
        extraModules = [ serverDisko ];
      };
      
    };
  };
}
