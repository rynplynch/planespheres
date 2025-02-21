{inputs}: {
  services.postgres."pg" = {
    enable = true;
    initialScript.before = ''
      CREATE DATABASE nakama;
      \c nakama;
      CREATE USER planespheres WITH password 'myserver';
      GRANT ALL PRIVILEGES ON DATABASE nakama to planespheres;
      GRANT USAGE, CREATE ON SCHEMA public TO planespheres;
    '';
  };
}
