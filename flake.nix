{
  description = "Turris flake";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem flake-utils.lib.allSystems (system: rec {
      packages = import ./pkgs {
        nixlib = nixpkgs.lib;
        nixpkgs = nixpkgs.legacyPackages.${system};
      };
    });
}
