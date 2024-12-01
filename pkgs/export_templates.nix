{
  fetchurl,
  runCommandCC,
  unzip,
}: let
  templates = fetchurl {
    url = "https://github.com/godotengine/godot/releases/download/4.3-stable/Godot_v4.3-stable_export_templates.tpz";
    hash = "sha256-9fENuvVqeQg0nmS5TqjCyTwswR+xAUyVZbaKK7Q3uSI=";
  };
in
  runCommandCC "build-export-templates"
  {
    buildInputs = [unzip];
  } ''
    unzip -j ${templates} -d $out

    interpreter=$(cat $NIX_CC/nix-support/dynamic-linker)
    patchelf --set-interpreter $interpreter $out/linux_*
  ''
