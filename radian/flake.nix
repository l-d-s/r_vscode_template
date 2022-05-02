{
  # Following 
  # https://github.com/DavHau/mach-nix/blob/master/examples.md#buildpythonpackage-from-github
  
inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    # This section will allow us to create a python environment
    # with specific predefined python packages from PyPi
    pypi-deps-db = {
      url = "github:DavHau/pypi-deps-db";
      inputs.mach-nix.follows = "mach-nix";
    };
    mach-nix = {
      url = "github:DavHau/mach-nix/3.4.0";
      inputs.pypi-deps-db.follows = "pypi-deps-db";
    };
  };

  outputs = {self, nixpkgs, mach-nix, flake-utils, pypi-deps-db }@inp:
    let
      l = nixpkgs.lib // builtins;
      supportedSystems = [ "x86_64-linux" "aarch64-darwin" ];
      forAllSystems = f: l.genAttrs supportedSystems
        (system: f system (import nixpkgs {inherit system;}));
    in
    {
    # enter this python environment by executing `nix shell .`
    defaultPackage = 
        forAllSystems (system: pkgs: 
          mach-nix.lib."${system}".buildPythonApplication {
            src = builtins.fetchGit {
              url = "https://github.com/randy3k/radian/";
              ref = "refs/tags/v0.6.1";
              rev = "1cab858b24eed3749c6b5e99ed1cfe26e144ac5d";
            };
          }
        );
    };
}