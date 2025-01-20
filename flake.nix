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
      url = "path:/home/ryanl/git-repos/godot-projects/planespheres/planespheres_client/materials/";
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
          config = {};
        };
        packages.default = self'.packages.nixos_template;

        packages.nixos_template = pkgs.callPackage ./pkgs/mkNixosPatch.nix {
          version = "1.0.0";
          pname = "nixos_template";
          src = self'.packages.spheres-of-fun;
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
        packages.spheres-of-fun = pkgs.callPackage ./pkgs/mkGodot.nix {
          export_templates = self'.packages.export-templates;

          spheres-of-fun-materials = inputs.spheres-of-fun-materials;
          version = "1.0.0";
          pname = "linux_template";
          src = ./src;
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
