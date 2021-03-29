{ ... }:

let
  hedgedocUsername = builtins.readFile "/var/secrets/hedgedoc/database_user";
  hedgedocPassword = builtins.readFile "/var/secrets/hedgedoc/database_password";
  hedgedocDatabase = builtins.readFile "/var/secrets/hedgedoc/database_name";
  ldapRootPassword = builtins.readFile "/var/secrets/ldap/password";
in
{
  services.hedgedoc = {
    enable = true;
    configuration = {
      dbURL = "postgres://${hedgedocUsername}:${hedgedocPassword}@localhost:5432/${hedgedocDatabase}";
      allowAnonymous = false;
      email = false;
      ldap = {
        searchBase = "ou=users,dc=cmgn,dc=io";
        bindDn = "cn=root,dc=cmgn,dc=io";
        bindCredentials = ldapRootPassword;
        searchAttributes = [ "uid" ];
        searchFilter = "(uid={{username}})";
        url = "ldap:///";
        tlsca = "server-cert.pem,root.pem";
        useridField = "uid";
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
