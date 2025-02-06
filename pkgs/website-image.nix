{
  website,
  dockerTools,
  lib,
  buildEnv,
  runtimeShell,
}: let
  image = dockerTools.buildImage {
    name = lib.strings.concatStrings ["rynplynch/" website.pname];
    tag = website.version;

    copyToRoot = buildEnv {
      name = "image-root";
      paths = [website];
      pathsToLink = ["/bin"];
    };

    runAsRoot = ''
      #!${runtimeShell}
      mkdir -p /tmp
    '';

    config = {
      Cmd = [website.pname];

      ExposedPorts = {
        "${website.port}/tcp" = {};
      };
    };
  };
in
  image
