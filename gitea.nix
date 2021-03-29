{ ... }:
let
  giteaUsername = builtins.readFile "/var/secrets/gitea/database_user";
  giteaDatabase = builtins.readFile "/var/secrets/gitea/database_name";
in
{
  services.gitea = {
    enable = true;
    httpPort = 6000;
    database = {
      type = "postgres";
      port = 5432;
      user = giteaUsername;
      passwordFile = "/var/secrets/gitea/database_password";
      name = giteaDatabase;
    };
    rootUrl = "https://git.cmgn.io";
    disableRegistration = false;
  };

  services.postgresql = {
    ensureDatabases = [
      giteaDatabase
    ];
    ensureUsers = [
      {
        name = giteaUsername;
        ensurePermissions = {
          "DATABASE ${giteaDatabase}" = "ALL PRIVILEGES";
        };
      }
    ];
  };
}
