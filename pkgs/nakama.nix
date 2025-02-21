{
  config,
  lib,
  pkgs,
  ...
}: {
  options = {
    services.nakama = {
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
