{
  description = "R set up with VSCode, radian, httpgd";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/21.11";
    radian.url = "./radian";
    # radian.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, radian }:
    let 
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      vscodeRPackages = with pkgs.rPackages; [
        languageserver
        httpgd
        rlang
        jsonlite
        # needed for knitr I think
        devtools
      ];
      extraRPackages = with pkgs.rPackages; [
        tidyverse

        # graphics
        cowplot
        lemon
        patchwork

        # bayes
        brms
        rstanarm
        tidybayes
        bayesplot
        rjags
      ];
      RWithPackages =
        pkgs.rWrapper.override{
          packages = vscodeRPackages ++ extraRPackages;
        };
      # RStudioWithPackages =
      #   pkgs.rstudioWrapper.override {
      #     packages = vscodeRPackages ++ extraRPackages;
      #   };
    in {
      devShell.x86_64-linux =
        pkgs.mkShell { 
          # need to add
          # export R_LIBS_SITE=$(R --slave -e 'paste0(.Library.site, collapse = ":")' | sed 's/\[1\] "//g' | sed 's/"//g')
          buildInputs = [
            # note: a derivation, not the flake itself
            # https://discourse.nixos.org/t/flakes-buildinputs-and-devshell/16208
            radian.defaultPackage.x86_64-linux

            RWithPackages
            # RStudioWithPackages

            pkgs.pandoc
          ];
        };
    };
}
