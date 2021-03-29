{ ... }:
let
  giteaUsername = builtins.readFile "/var/secrets/gitea/database_user";
  giteaDatabase = builtins.readFile "/var/secrets/gitea/database_name";
  giteaSmtpUsername = builtins.readFile "/var/secrets/gitea/mail_username";
  giteaSmtpPassword = builtins.readFile "/var/secrets/gitea/mail_password";
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
    settings = {
      mailer = {
        ENABLED = "true";
        HOST = "smtp.gmail.com:465";
        FROM = "services@cmgn.io";
        MAILER_TYPE = "smtp";
        IS_TLS_ENABLED = "true";
        USER = giteaSmtpUsername;
        PASSWD = giteaSmtpPassword;
      };
    };
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
