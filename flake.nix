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
    spheres-of-fun-materials = {
      url = "path:/home/ryanl/git-repos/godot-projects/Spheres-of-Fun/src/materials/";
      flake = false;
    };
  };

        pkgs = import nixpkgs {
          inherit system;
          overlays = [(import ./overlays.nix {inherit inputs;})];
        };

        version = "1.0.0";
      in rec {
        apps.nixos_template = flake-utils.lib.mkApp {
          drv = self.packages.${system}.nixos_template;
        };
  outputs = inputs @ {flake-parts, ...}:
  # generate the flake, while passing input attributes
    flake-parts.lib.mkFlake {inherit inputs;} {
      # different systems that rplwork can be built for
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];

        packages.default = packages.nixos_template;
      # helper function that handles ${system} for us
      perSystem = {
        # used to reference nixpkgs, called because we inherited inputs
        pkgs,
        self',
        ...
      }: {

        packages.nixos_template = pkgs.mkNixosPatch {
          inherit version;
          pname = "nixos_template";
          src = packages.linux_template;
        };

        packages.linux_template = pkgs.mkGodot {
          inherit version spheres-of-fun-materials;
          pname = "linux_template";
          src = ./src;
          preset = "linux"; # You need to create this preset in godot
        };

        packages.windows_template = pkgs.mkGodot {
          inherit version spheres-of-fun-materials;
          pname = "windows_template";
          src = ./src;
          preset = "windows"; # You need to create this preset in godot
        };

        packages.export_templates = pkgs.export_templates;

        formatter = pkgs.alejandra;

        # development environment used to work on dotnet source code
        # enter using 'nix develop'
        devShells.default = pkgs.mkShell {
          buildInputs = [
            (
              with pkgs;
                mkShell [
                  blender
                  godot_4
                ]
            )
          ];
        };
      };
    };
}
