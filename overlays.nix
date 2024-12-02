{inputs, ...}: final: _prev: {
  blender = _prev.blender ./pkgs/blender.nix {};
  mkGodot = _prev.callPackage ./pkgs/mkGodot.nix {};
  mkNixosPatch = _prev.callPackage ./pkgs/mkNixosPatch.nix {};
  export_templates = _prev.callPackage ./pkgs/export_templates.nix {};
}
