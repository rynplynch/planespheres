{
  lib,
  stdenv,
  godot_4,
  uutils-coreutils-noprefix,
  fontconfig,
  copyDesktopItems,
  export_templates,
  plane-spheres-materials-tar,
  pname,
  version,
  src,
  preset,
  desktopItems ? [],
  exportMode ? "release", # release / debug / pack
  exportTemplates ? export_templates, # absolute path to the nix store
}: let
  meta.mainProgram = pname;
  godot-build = stdenv.mkDerivation rec {
    inherit pname version src desktopItems;

    buildInputs = [
      copyDesktopItems
      godot_4
      uutils-coreutils-noprefix
    ];

    postPatch = ''
      patchShebangs scripts
    '';

    buildPhase = ''
      runHook preBuild

      export HOME=$TMPDIR

      mkdir -p /build/.local/share/godot/export_templates/

      ln -s ${exportTemplates} /build/.local/share/godot/export_templates/4.3.stable

      ln -s ${plane-spheres-materials-tar}/store/*source/ /build/game/materials

      mkdir -p $out/share/${pname}
      godot4 --headless --export-${exportMode} "${preset}" \
        $out/share/${pname}/${pname}

      runHook postBuild
    '';
  };
in
  godot-build
