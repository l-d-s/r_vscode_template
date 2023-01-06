{
  symlinkJoin,
  radian,
  makeWrapper,
  packages,
  R,
}:
symlinkJoin {
  name = radian.name + "-wrapper";
  preferLocalBuild = true;
  allowSubstitutes = false;

  buildInputs = [ radian R ] ++ packages;
  paths = [ radian ];

  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    cd ${radian}/bin
    for exe in *; do
      rm "$out/bin/$exe"
      makeWrapper "${radian}/bin/$exe" "$out/bin/$exe" \
        --prefix "R_LIBS_SITE" ":" "$R_LIBS_SITE" \
        --prefix "PATH" ":" "${R}/bin"
    done
  '';
}
