{
  description = "Home Manager Configuration Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-flake.url = "github:shrugalic/home-flake";
    home-flake.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, home-flake, ... }: flake-utils.lib.eachDefaultSystem (system: rec {
    packages.darwin = home-flake.activationPackageFor {
      inherit system;
      homeDirectory = "/Users/boli";
      username = "boli";
      configuration = {
        nixpkgs.config.allowUnfree = true;
        imports = [
          home-flake.homeManagerModule
          # ./myconfig.nix # additional modules
        ];
        programs.git = {
          userName = "bOli";
          userEmail = "github.profile@bueechi.net";
        };
      };
    };

    defaultPackage = packages.darwin;
  });
}
