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

      # Generate the build files
      godot4 --headless --export-${exportMode} "${preset}" \
        $out/share/${pname}/${pname}

      # Here we are solving for the size of the pck and wasm files to later be substituted
      # Store the du command that returns the size of the desired file
      pckOutput=`coreutils --coreutils-prog=du -b $out/share/${pname}/${pname}.pck`
      wasmOutput=`coreutils --coreutils-prog=du -b $out/share/${pname}/${pname}.wasm`

      # Evaluate the du command, splitting the returned string by empty space, and save the first grouping
      # This is done to parse the output of the du command and isolate just the size of the file
      pckSize=`echo $pckOutput | coreutils --coreutils-prog=cut -d ' '  -f1`
      wasmSize=`echo $wasmOutput | coreutils --coreutils-prog=cut -d ' '  -f1`

      # Find and replace strings in the default html file generated by Godot
      # Further detail as to what each does here: [Godot doc](https://docs.godotengine.org/en/stable/tutorials/platform/web/customizing_html5_shell.html)
      substituteInPlace $out/share/${pname}/${pname}.html \
         --replace-fail "\$GODOT_CONFIG" "{
           'args':[],
           'canvasResizePolicy':2,
           'ensureCrossOriginIsolationHeaders':true,
           'executable':'${pname}',
           'experimentalVK':false,
           'fileSizes':{
             '${pname}.pck':  "$pckSize",
             '${pname}.wasm': "$wasmSize"
           },
           'focusCanvas':true,
           'gdextensionLibs':[]
         }" \
         --replace-fail "\$GODOT_THREADS_ENABLED" "false" \
         --replace-fail "\$GODOT_SPLASH" "${pname}.png" \
         --replace-fail "\$GODOT_HEAD_INCLUDE" "" \
         --replace-fail "\$GODOT_PROJECT_NAME" "${pname}" \
         --replace-fail "\$GODOT_URL" "${pname}.js"

      runHook postBuild
    '';
  };
in
  godot-build
