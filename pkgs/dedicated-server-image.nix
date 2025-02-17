{
  glibc,
  server,
  dockerTools,
  lib,
}: let
  image = dockerTools.buildLayeredImage {
    name = lib.strings.concatStrings ["rynplynch/" server.pname];
    tag = server.version;
    contents = [glibc];
    config.Cmd = [
      "${server}/bin/${server.pname}"
    ];
  };
in
  image
