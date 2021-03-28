{ ... }:
let
    keycloakUsername = builtins.readFile "/var/secrets/keycloak/database_user";
    keycloakPasswordFile = "/var/secrets/keycloak/database_password";
    keycloakDatabase = builtins.readFile "/var/secrets/keycloak/database_name";
    keycloakAdminPassword = builtins.readFile "/var/secrets/keycloak/admin_password";
in {
  services.keycloak = {
    enable = true;
    bindAddress = "127.0.0.1";
    httpPort = "10080";
    httpsPort = "10443";
    databaseType = "postgresql";
    databasePort = 5432;
    databaseHost = "localhost";
    databaseUsername = keycloakUsername;
    databasePasswordFile = keycloakPasswordFile;
    frontendUrl = "https://keycloak.cmgn.io/auth";
    initialAdminPassword = keycloakAdminPassword;
    extraConfig = {
      "subsystem=undertow" = {
        "server=default-server" = {
          "http-listener=default" = {
            "proxy-address-forwarding" = true;
          };
          "https-listener=https" = {
            "proxy-address-forwarding" = true;
          };
        };
      };
    };
  };

  services.postgresql = {
    ensureDatabases = [
      keycloakDatabase
    ];
    ensureUsers = [
      {
        name = keycloakUsername;
        ensurePermissions = {
          "DATABASE ${keycloakDatabase}" = "ALL PRIVILEGES";
        };
      }
    ];
  };
}
