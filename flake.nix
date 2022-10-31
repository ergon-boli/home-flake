{
  description = "My home-manager setup";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
#   flake-utils.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    flake-utils,
    ...
  }: {
    # overlay = import ./overlay.nix inputs;
    homeManagerModules = {
      base = {
        # nixpkgs.overlays = [self.overlay];
        imports = [
          ./modules/nixBase.nix
          # ./modules/direnv.nix
        ];
      };
      boli = {
        imports = [
          ./config/common.nix
          ./config/git.nix
          ./config/fish.nix
        ];
      };
    };

    lib.homeConfigurations = homes:
      flake-utils.lib.eachDefaultSystem (system: let
        pkgs = import nixpkgs {
          inherit system;
          # option nixpkgs.config.allowUnfree currently not working
          # https://github.com/nix-community/home-manager/issues/2954
          config = {allowUnfree = true;};
        };
        configurations = builtins.removeAttrs homes ["default"];
        mkHomeConfig = name: configuration:
          home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [{home.username = name;} configuration];
          };
        mkActivationPackage = _: homeConfiguration: homeConfiguration.activationPackage;
      in rec {
        homeConfigurations = builtins.mapAttrs mkHomeConfig configurations;
        packages =
          (builtins.mapAttrs mkActivationPackage homeConfigurations)
          // pkgs.lib.optionalAttrs (homes ? default) {default = packages.${homes.default};};
      });

    homeConfigurationWithActivations = {
      username,
      configuration,
      name ? username,
      asDefaultPackage ? true,
    }:
      flake-utils.lib.eachDefaultSystem (system: rec {
        homeConfigurations."${name}" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [{home.username = username;} configuration];
        };
        packages =
          {
            ${name} = homeConfigurations."${username}".activationPackage;
          }
          // nixpkgs.lib.optionalAttrs asDefaultPackage {
            default = packages.${name};
          };
      });

    defaultTemplate = {
      description = "Template to use nix-home";
      path = ./template;
    };
  };
}
