{
  description = "My home-manager setup";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }: {
   # overlay = import ./overlay.nix inputs;
    homeManagerModule = {
   #   nixpkgs.overlays = [self.overlay];
      imports = [
        ./modules/direnv.nix
        ./modules/common.nix
        ./modules/git.nix
        ./modules/fish.nix
      ];
    };
    activationPackageFor = def: let
      configuration = home-manager.lib.homeManagerConfiguration def;
    in configuration.activationPackage;

    defaultTemplate = {
      description = "Template to use nix-home";
      path = ./template;
    };

    homeManagerConfigurations = {
      base = home-manager.lib.homeManagerConfiguration {
        configuration = {
          imports = [self.homeManagerModule];
        };
        system = "aarch64-darwin";
        homeDirectory = "/Users/boli";
        username = "boli";
      };
    };
    homeManagerConfiguration = self.homeManagerConfigurations.base;
    defaultPackage = {
    	x86_64-darwin = self.homeManagerConfiguration.activationPackage;
    	aarch64-darwin = self.homeManagerConfiguration.activationPackage;
    };
  };
}