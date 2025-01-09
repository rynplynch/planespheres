{
  description = "Godot development environment";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "nixpkgs/nixos-unstable";

    # This input represents large static files I don't want in the repo
    # I plan on hosting these files using the same domain hosting the web build
    # TODO: change url to endpoint that servers static files
    spheres-of-fun-materials = {
      url = "path:/home/ryanl/git-repos/godot-projects/Spheres-of-Fun/src/materials/";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    spheres-of-fun-materials,
  } @ inputs:
    flake-utils.lib.eachDefaultSystem
    (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [(import ./overlays.nix {inherit inputs;})];
        };

        version = "1.0.0";
      in rec {
        apps.nixos_template = flake-utils.lib.mkApp {
          drv = self.packages.${system}.nixos_template;
        };

        packages.default = packages.nixos_template;

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

        devShell = with pkgs; mkShell {
          buildInputs = [
            godot_4
            blender
          ];
        };
      }
    )
    // {
      templates.default = {
        description = "";
        path = ./.;
      };
    };
}
