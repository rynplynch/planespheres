{inputs}: {
  services.postgres."pg" = {
    enable = true;
    initialDatabases = [
      {
        name = "planespheres";
      }
    ];
  };
}
