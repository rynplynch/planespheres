{
  description = "A game made using the Godot engine. Currently roll around as a sphere!";

  inputs = {
    # helpful tools for maintaining the flake
    flake-parts.url = "github:hercules-ci/flake-parts";

    # use 'nix flake update' to bump the version of nixpkgs used
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # This input represents large static files I don't want in the repo
    # I plan on hosting these files using the same domain hosting the web build
    # TODO: change url to endpoint that servers static files
    plane-spheres-materials = {
      url = "path:/home/ryanl/git-repos/godot-projects/planespheres/game/materials/";
      flake = false;
    };

    # helpful tool to manage dotnet nuget dependencies
    nuget-packageslock2nix = {
      url = "github:mdarocha/nuget-packageslock2nix/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {flake-parts, ...}:
  # generate the flake, while passing input attributes
    flake-parts.lib.mkFlake {inherit inputs;} {
      # different systems that we support, need other machines for testing
      systems = ["x86_64-linux"];

      # helper function that handles ${system} for us
      perSystem = {
        pkgs,
        self',
        system,
        ...
      }: {
        # Alter the packages argument of our flake expression
        _module.args.pkgs = import inputs.nixpkgs {
          # Build packages from nixpkgs for the current system
          inherit system;

          # Customize packages from nixpkgs
          overlays = [
            (final: prev: {
            })
          ];

          # Further customization of nixpkgs
          config = {
            # godot_4-mono requires this
            # TODO: godot minimum version changing soon https://godotengine.org/article/godotsharp-packages-net8/
            permittedInsecurePackages = [
              "dotnet-sdk-6.0.428"
            ];
          };
        };
        # assign the default package to run with 'nix run .'
        apps.default = {
          type = "app";
          # self' = self prime
          # self' allows us to reference the future derivation that is created with this flake
          program = self'.packages.nix-build;
        };

                    # If no package specified call this one, 'nix build .'
        packages.default = self'.packages.nix-build;

        # Wrap godot build for linux enviroment
        packages.nix-build = pkgs.callPackage ./pkgs/mkNixosPatch.nix {
          version = "1.0.0";
          pname = "nix-build";
          src = self'.packages.linux-build;
        };


        # call the rplwork_client nix module and expose it via the packages.rplwork attribute
        # this is what is referenced with self'.packages.rplwork_client
        packages.linux-build = pkgs.callPackage ./pkgs/linux-build.nix {
          # fetch export templates, provided by godot team to help build
          export_templates = pkgs.godot_4-export-templates;

          plane-spheres-materials = inputs.plane-spheres-materials;
          version = "1.0.0";
          pname = "linux_template";
          src = ./game;
          preset = "linux"; # You need to create this preset in godot
        };

        packages.web-build-wrapper = pkgs.callPackage ./pkgs/web-build-wrapper.nix{
            web-build = self'.packages.web-build;
        };

        packages.web-build = pkgs.callPackage ./pkgs/web-build.nix {
          # fetch export templates, provided by godot team to help build
          export_templates = pkgs.godot_4-export-templates;

          plane-spheres-materials = inputs.plane-spheres-materials;
          version = "1.0.0";
          pname = "index";
          src = ./game;
          preset = "Web"; # You need to create this preset in godot
        };

        packages.website = pkgs.callPackage ./pkgs/website.nix {
          inherit inputs;
          web-build = self'.packages.web-build;
        };

        # use 'nix fmt' before committing changes in git
        formatter = pkgs.alejandra;

        # development environment used to work on dotnet source code
        # enter using 'nix develop'
        devShells.default = pkgs.mkShell {
          buildInputs = [
            # used for developing the game itself
            pkgs.godot_4
            pkgs.blender
            # used for developing the website
            pkgs.dotnetCorePackages.dotnet_9.sdk
            pkgs.dotnetCorePackages.dotnet_9.aspnetcore
            pkgs.python3
          ];
        };
      };
    };
}
