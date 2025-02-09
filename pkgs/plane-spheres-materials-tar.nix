{
  inputs,
  runCommandWith,
}: let
  # materials/assets used during the building of plane-spheres
  plane-spheres-materials = inputs.plane-spheres-materials;
in
  runCommandWith {
    name = "plane-spheres-materials-tar";
  } ''
    mkdir -p $out
    tar -czvf plane-spheres-materials.tar.gz ${plane-spheres-materials}
    mv plane-spheres-materials.tar.gz $out
  ''
