{ ... }:

let
  hedgedocUsername = builtins.readFile "/var/secrets/hedgedoc/database_user";
  hedgedocPassword = builtins.readFile "/var/secrets/hedgedoc/database_password";
  hedgedocDatabase = builtins.readFile "/var/secrets/hedgedoc/database_name";
in
{
  services.hedgedoc = {
    enable = true;
    configuration = {
      dbURL = "postgres://${hedgedocUsername}:${hedgedocPassword}@localhost:5432/${hedgedocDatabase}";
      allowAnonymous = false;
      saml = {
        issuer = "hedgedoc";
        identifierFormat = "urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified";
        idpSsoUrl = "https://keycloak.cmgn.io/auth/realms/master/protocol/saml";
        idpCert = "/var/secrets/hedgedoc/idp";
      };
    };
  };

  services.postgresql = {
    ensureDatabases = [
      hedgedocDatabase
    ];
    ensureUsers = [
      {
        name = hedgedocUsername;
        ensurePermissions = {
          "DATABASE ${hedgedocDatabase}" = "ALL PRIVILEGES";
        };
      }
    ];
  };
}
