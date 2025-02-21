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
      };
    };
}
