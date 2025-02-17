{
  stdenv,
  godot_4,
  copyDesktopItems,
  export_templates,
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

    # TODO: make it so Godot looks for this attribute via an environment variable.
    port = "2000";

    buildInputs = [
      copyDesktopItems
      godot_4
    ];

    postPatch = ''
      patchShebangs scripts
    '';

    buildPhase = ''
      runHook preBuild

      export HOME=$TMPDIR

      mkdir -p /build/.local/share/godot/export_templates/

      ln -s ${exportTemplates} /build/.local/share/godot/export_templates/4.3.stable

      mkdir -p $out/share/${pname}
      godot4 --headless --export-${exportMode} "${preset}" \
        $out/share/${pname}/${pname}

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin

      ln -s $out/share/${pname}/${pname} $out/bin

      patchelf --set-interpreter /lib64/ld-linux-x86-64.so.2 \
      $out/share/${pname}/${pname}

      runHook postInstall
    '';
  };
in
  godot-build
