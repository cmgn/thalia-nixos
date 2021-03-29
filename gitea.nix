{ ... }:
let
  giteaUsername = builtins.readFile "/var/secrets/gitea/database_user";
  giteaPassword = builtins.readFile "/var/secrets/gitea/database_password";
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
      password = giteaPassword;
      name = giteaDatabase;
    };
    rootUrl = "https://git.cmgn.io";
    disableRegistration = true;
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
