{ pkgs, ... }:
{
  services.openldap = {
    enable = true;
    urlList = [ "ldap:///" ];
    settings = {
      children = {
        "cn=schema".includes = [
           "${pkgs.openldap}/etc/schema/core.ldif"
           "${pkgs.openldap}/etc/schema/cosine.ldif"
           "${pkgs.openldap}/etc/schema/inetorgperson.ldif"
           "${pkgs.openldap}/etc/schema/nis.ldif"
        ];
        "olcDatabase={-1}frontend" = {
          attrs = {
            objectClass = "olcDatabaseConfig";
            olcDatabase = "{-1}frontend";
            olcAccess = [
              "{0}to *  by * read"
            ];
          };
        };
        "olcDatabase={0}config" = {
          attrs = {
            objectClass = "olcDatabaseConfig";
            olcDatabase = "{0}config";
            olcAccess = [ "{0}to * by * none break" ];
          };
        };
        "olcDatabase={1}mdb" = {
          attrs = {
            objectClass = [ "olcDatabaseConfig" "olcMdbConfig" ];
            olcDatabase = "{1}mdb";
            olcDbDirectory = "/var/db/ldap";
            olcDbIndex = [
              "objectClass eq"
              "cn pres,eq"
              "uid pres,eq"
              "sn pres,eq,subany"
            ];
            olcRootDN = "cn=root,dc=cmgn,dc=io";
            olcRootPW = {
              path = "/var/secrets/ldap/password";
            };
            olcSuffix = "dc=cmgn,dc=io";
            olcAccess = [ "{0}to * by * read break" ];
            olcMonitoring = "TRUE";
          };
        };
      };
    };
    declarativeContents = {
      "dc=cmgn,dc=io" = ''
        dn: dc=cmgn,dc=io
        objectClass: top
        objectClass: dcObject
        objectClass: organization
        o: cmgn.io
        dc: cmgn

        dn: ou=users,dc=cmgn,dc=io
        objectClass: top
        objectClass: organizationalUnit
        ou: users

        dn: cn=cmgn,ou=users,dc=cmgn,dc=io
        objectClass: top
        objectClass: person
        cn: cmgn
        sn: cmgn
        userPassword: {SSHA}VGyNXmekG29OemJ/4cDQVc88rCKhLf7/
      '';
    };
  };
}
