{
  description = "A game made using the Godot engine. Currently roll around as a sphere!";

  inputs = {
    # helpful tools for maintaining the flake
    flake-parts.url = "github:hercules-ci/flake-parts";

    # use nix flake update to bump the version of nixpkgs used
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # This input represents large static files I don't want in the repo
    # I plan on hosting these files using the same domain hosting the web build
    # TODO: change url to endpoint that servers static files
    plane-spheres-materials = {
      url = "path:/home/ryanl/git-repos/godot-projects/planespheres/game/materials/";
      flake = false;
    };
  };

  outputs = inputs @ {flake-parts, ...}:
  # generate the flake, while passing input attributes
    flake-parts.lib.mkFlake {inherit inputs;} {
      # different systems that rplwork can be built for
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];

      # helper function that handles ${system} for us
      perSystem = {
        # used to reference nixpkgs, called because we inherited inputs
        pkgs,
        self',
        system,
        ...
      }: {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [
            (final: prev: {
            })
          ];
          config = {
            # godot_4-mono requires this
            # TODO: godot minimum version changing soon https://godotengine.org/article/godotsharp-packages-net8/
            permittedInsecurePackages = [
              "dotnet-sdk-6.0.428"
            ];
          };
        };
        packages.default = self'.packages.nixos_template;

        packages.nixos_template = pkgs.callPackage ./pkgs/mkNixosPatch.nix {
          version = "1.0.0";
          pname = "nixos_template";
          src = self'.packages.plane-spheres;
        };
        # assign the default package to run with 'nix run .'
        apps.default = {
          type = "app";
          # self' = self prime
          # self' allows us to reference the future derivation that is created with this flake
          program = self'.packages.nixos_template;
        };

        # call the rplwork_client nix module and expose it via the packages.rplwork attribute
        # this is what is referenced with self'.packages.rplwork_client
        packages.plane-spheres = pkgs.callPackage ./pkgs/mkGodot.nix {
          export_templates = self'.packages.export-templates;

          plane-spheres-materials = inputs.plane-spheres-materials;
          version = "1.0.0";
          pname = "linux_template";
          src = ./game;
          preset = "linux"; # You need to create this preset in godot
        };

        # the export templates are presets to help build our game for different systems
        packages.export-templates = pkgs.callPackage ./pkgs/export_templates.nix {};

        # use 'nix fmt' before committing changes in git
        formatter = pkgs.alejandra;

        # development environment used to work on dotnet source code
        # enter using 'nix develop'
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.blender
            pkgs.godot_4-mono
          ];
        };
      };
    };
}
