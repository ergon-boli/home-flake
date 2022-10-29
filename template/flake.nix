{
  description = "Home Manager Configuration";

  inputs = {
    home-flake.url = "github:shrugalic/home-flake";
    nixpkgs.follows = "home-flake/nixpkgs";
    flake-utils.follows = "home-flake/flake-utils";
    #in case you need to use a different nixpkgs
    #nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    #home-flake.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {
    nixpkgs,
    flake-utils,
    home-flake,
    ...
  }:
    home-flake.lib.homeConfigurations {
      default = "boli";
      boli = {
        imports = [
          # include modules: local or from other flakes
          home-flake.homeManagerModules.base
          home-flake.homeManagerModules.boli
          # ./myconfig.nix # additional modules
        ];
        # additional inline configuration
        programs.git = {
          userName = "bOli";
          userEmail = "github.profile@bueechi.net";
        };
      };
    }
    // flake-utils.lib.eachDefaultSystem (system: {
      formatter = nixpkgs.legacyPackages.${system}.alejandra;
    });
}
