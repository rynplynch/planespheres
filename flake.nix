{
  description = "A game made using the Godot engine. Currently roll around as a sphere!";

  inputs = {
    # helpful tools for maintaining the flake
    flake-parts.url = "github:hercules-ci/flake-parts";

    # create and manages process
    process-compose-flake.url = "github:Platonic-Systems/process-compose-flake";

    # create packages from process?
    services-flake.url = "github:juspay/services-flake";

    # use 'nix flake update' to bump the version of nixpkgs used
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # WARN: in order to build the website image you must have the uncompressed assets for the game
    plane-spheres-materials = {
      url = "path:/home/ryanl/git-repos/godot-projects/planespheres/game/materials/";
      flake = false;
    };

    # TODO: I should pull these resource directly from where they are hosted, ie. polyhaven.com
    plane-spheres-materials-tar = {
      url = "https://www.planespheres.com/materials/plane-spheres-materials.tar.gz";
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

      imports = [
        # import the flake module of process-compose
        inputs.process-compose-flake.flakeModule
      ];

      flake.processComposeModules.default =
        import ./services.nix {inherit inputs;};

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

          plane-spheres-materials-tar = inputs.plane-spheres-materials-tar;
          version = "1.0.0";
          pname = "linux_template";
          src = ./game;
          preset = "linux"; # You need to create this preset in godot
        };

        packages.web-build = pkgs.callPackage ./pkgs/web-build.nix {
          # fetch export templates, provided by godot team to help build
          export_templates = pkgs.godot_4-export-templates;

          plane-spheres-materials-tar = inputs.plane-spheres-materials-tar;
          version = "1.0.0";
          pname = "PlaneSpheres";
          src = ./game;
          preset = "Web"; # You need to create this preset in godot
        };

        packages.dedicated-server-build = pkgs.callPackage ./pkgs/dedicated-server-build.nix {
          # fetch export templates, provided by godot team to help build
          export_templates = pkgs.godot_4-export-templates;
          version = "1.0.0";
          pname = "planespheres-dedicated-server";
          src = ./server;
          preset = "Linux"; # You need to create this preset in godot
        };

        packages.dedicated-server-image = pkgs.callPackage ./pkgs/dedicated-server-image.nix {
          server = self'.packages.dedicated-server-build;
        };

        packages.website = pkgs.callPackage ./pkgs/website.nix {
          inherit inputs;
          web-build = self'.packages.web-build;
          plane-spheres-materials-tar = self'.packages.plane-spheres-materials-tar;
        };

        # creates a tar ball of our local game assets/materials
        packages.plane-spheres-materials-tar = pkgs.callPackage ./pkgs/plane-spheres-materials-tar.nix {
          inherit inputs;
        };

        packages.website-image = pkgs.callPackage ./pkgs/website-image.nix {
          website = self'.packages.website;
        };

        # use process-compose to create a new service
        process-compose."nakama" = {config, ...}: {
          imports = [
            # allows use to create our own service
            inputs.services-flake.processComposeModules.default
            # imports the postgres service our service depends on
            inputs.self.processComposeModules.default
            # import the nakama service that uses the nakama pkg
            ./pkgs/nakama.nix
          ];
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
          ];
        };
      };
    };
}
