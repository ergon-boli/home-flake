{
  description = "My home-manager setup";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    #   flake-utils.inputs.nixpkgs.follows = "nixpkgs";
    hunk = {
      url = "github:modem-dev/hunk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    flake-utils,
    ...
  }: {
    homeManagerModules = {
      base = {
        imports = [
          ./modules/nixBase.nix
          # ./modules/direnv.nix
        ];
      };
      boli = {
        imports = [
          inputs.hunk.homeManagerModules.default
          ./config/common.nix
          ./config/git.nix
          ./config/fish.nix
        ];
      };
    };

    # see ./template/flake.nix for usage
    # lib.homeConfigurations is a function:
    # - input: attrSet["username" => "home-manager-module"]
    #          (special attribute name default="defaultUser")
    # - generates homeConfigurations.<username> for every module & architecture
    # - generates packages.$system.<username> exposing the activation script
    # - generates packages.$system.default for the defaultUser name
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

    defaultTemplate = {
      description = "Template to use nix-home";
      path = ./template;
    };
  };
}
