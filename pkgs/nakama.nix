{
  config,
  lib,
  pkgs,
  ...
}: {
  options = {
    services.nakama = {
      enable = lib.mkEnableOption "Enable nakama service";
      package = lib.mkPackageOption pkgs "nakama" {};
    };
  };

  config = let
    cfg = config.services.nakama;
  in
    lib.mkIf cfg.enable {
      settings.processes = {
        init = {
          command = "
            ${lib.getExe cfg.package} migrate up --database.address planespheres:myserver@127.0.0.1:5432
            ";
          # this is checking the health of the postgres service found in services.nix
          depends_on."pg".condition = "process_healthy";
        };
        nakama = {
            command = "
            ${lib.getExe cfg.package} --database.address planespheres:myserver@127.0.0.1:5432
            ";
          # only run after the init command is done
          depends_on."init".condition = "process_completed_successfully";
        };
      };
    };
}
