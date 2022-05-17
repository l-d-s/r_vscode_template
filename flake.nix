{
  # Following
  # https://github.com/DavHau/mach-nix/blob/master/examples.md#buildpythonpackage-from-github

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/21.11";
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.nixpkgs.follows = "nixpkgs";
    flake-compat.url = "github:edolstra/flake-compat";
    flake-compat.flake = false;
    flake-compat.inputs.nixpkgs.follows = "nixpkgs";
    # This section will allow us to create a python environment
    # with specific predefined python packages from PyPi
    pypi-deps-db = {
      url = "github:DavHau/pypi-deps-db/a1ff486da6bafcba0a5f64fec87a583d544ea374";
      inputs.mach-nix.follows = "mach-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mach-nix = {
      url = "github:DavHau/mach-nix/3.4.0";
      inputs.pypi-deps-db.follows = "pypi-deps-db";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    mach-nix,
    flake-utils,
    pypi-deps-db,
    flake-compat,
    ...
  } @ inp: 
  let
    l = nixpkgs.lib // builtins;
    supportedSystems = ["x86_64-linux" "aarch64-darwin"];
    forAllSystems = f:
      l.genAttrs supportedSystems
      (system: f system (import nixpkgs {inherit system;}));
    vscodeRPackages = [
      "languageserver"
      "httpgd"
      "rlang"
      "jsonlite"
      # needed for knitr I think
      "devtools"
    ];
    extraRPackages = [
      "tidyverse"

      # graphics
      "cowplot"
      "lemon"
      "patchwork"

      # bayes
      "brms"
      "rstanarm"
      "tidybayes"
      "bayesplot"
      # "rjags"
    ];
    rPackageList = vscodeRPackages ++ extraRPackages;
  in 
  {
    # enter this python environment by executing `nix shell .`
    defaultPackage = forAllSystems (
      system: pkgs: let
        radian = mach-nix.lib."${system}".buildPythonApplication {
          src = builtins.fetchGit {
            url = "https://github.com/randy3k/radian/";
            ref = "refs/tags/v0.6.1";
            rev = "1cab858b24eed3749c6b5e99ed1cfe26e144ac5d";
          };
        };

        radianWrapper = pkgs.callPackage ./wrapper.nix {
          inherit radian;
          packages = l.attrValues (l.getAttrs rPackageList pkgs.rPackages);
        };
      in
        radianWrapper
    );
  };
}
