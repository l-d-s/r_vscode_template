{
  # Following
  # https://github.com/DavHau/mach-nix/blob/master/examples.md#buildpythonpackage-from-github

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/22.05";
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.nixpkgs.follows = "nixpkgs";
    # For legacy Nix installs, to create a shell
    flake-compat.url = "github:edolstra/flake-compat";
    flake-compat.flake = false;
    flake-compat.inputs.nixpkgs.follows = "nixpkgs";
    # This section will allow us to create a python environment
    # with specific predefined python packages from PyPi
    pypi-deps-db = {
      url = "github:DavHau/pypi-deps-db/982b6cdf6552fb9296e1ade29cf65a2818cbbd6b";
      inputs.mach-nix.follows = "mach-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mach-nix = {
      url = "github:DavHau/mach-nix/3.5.0";
      inputs.pypi-deps-db.follows = "pypi-deps-db";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    mach-nix,
    flake-utils,
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
    extraRPackages = import ./extra_r_packages.nix;
    rPackageList = vscodeRPackages ++ extraRPackages;
  in
  {
    # enter this python environment by executing `nix shell .`
    devShell = forAllSystems (
      system: pkgs: let
        radian = mach-nix.lib."${system}".mkPython {
          requirements = "radian";
        };
        rPackages = l.attrValues (l.getAttrs rPackageList pkgs.rPackages);
        radianWrapper = pkgs.callPackage ./radian_wrapper.nix {
          inherit radian;
          packages = rPackages;
        };

        rWrapper = pkgs.rWrapper.override {
          packages = rPackages;
        };
      in
        pkgs.mkShell { 
          shellHook = "export RADIAN_BIN=${radian.outPath}/bin/radian";
          buildInputs = [ radianWrapper rWrapper pkgs.vscode ]; }
    );
  };
}
