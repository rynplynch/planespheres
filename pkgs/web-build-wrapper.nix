{ lib
, python3Packages
, src
, web-build
}:

python3Packages.buildPythonApplication rec {
    inherit src;
    pname = "serve";
    version = "0.1.0";
    pyproject = false;

    propagatedBuildInputs = [
        # List of dependencies
        python3Packages.httpx
        web-build
    ];

    # Do direct install
    #
    # Add further lines to `installPhase` to install any extra data files if needed.
    dontUnpack = true;

    makeWrapperArgs = [
      "--set PLANE_SPHERES_PATH ${web-build}/share/${web-build.pname}"
    ];
    installPhase = ''
        install -Dm755 "${./${pname}}" "$out/bin/${pname}"
    '';
}
