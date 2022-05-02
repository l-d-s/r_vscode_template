{
  description = "R set up with VSCode, radian, httpgd";
  
  inputs = {
    radian.url = "./radian";
  };

  outputs = { self, nixpkgs, radian }:
    let pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in {
      devShell.x86_64-linux =
        pkgs.mkShell { 
          buildInputs = [
            # note: a derivation, not the flake itself
            # https://discourse.nixos.org/t/flakes-buildinputs-and-devshell/16208
            radian.defaultPackage.x86_64-linux
          ];
        };
    };
}
