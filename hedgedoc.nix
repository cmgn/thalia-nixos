{ config, pkgs, ... }:

# TODO(cmgn): Push the missing oauth2 fields upstream.

let
  hedgedocUsername = builtins.readFile "/var/secrets/hedgedoc/database_user";
  hedgedocPassword = builtins.readFile "/var/secrets/hedgedoc/database_password";
  hedgedocDatabase = builtins.readFile "/var/secrets/hedgedoc/database_name";
  hedgedocOauthSecret = builtins.readFile "/var/secrets/hedgedoc/oauth_secret";

  prettyJSON = conf:
    pkgs.runCommand "codimd-config.json" { preferLocalBuild = true; } ''
      echo '${builtins.toJSON conf}' | ${pkgs.jq}/bin/jq \
        '{production:del(.[]|nulls)|del(.[][]?|nulls)}' > $out
        '';

  configuration = {
    allowAnonymous = false;
    allowEmailRegister = false;
    allowGravatar = true;
    allowOrigin = [ "localhost" "md.cmgn.io" ];
    allowPDFExport = true;
    db = {};
    dbURL = "postgres://${hedgedocUsername}:${hedgedocPassword}@localhost:${toString config.services.postgresql.port}/${hedgedocDatabase}";
    defaultPermission = "editable";
    email = false;
    host = "localhost";
    hsts = {
      enable = true;
      includeSubdomains = true;
      maxAgeSeconds = 31536000;
      preload = true;
    };
    imageUploadType = "filesystem";
    imgur = {};
    indexPath = "./public/views/index.ejs";
    oauth2 = {
      authorizationURL = "https://keycloak.cmgn.io/auth/realms/master/protocol/openid-connect/auth";
      clientID = "hedgedoc";
      clientSecret = hedgedocOauthSecret;
      tokenURL = "https://keycloak.cmgn.io/auth/realms/master/protocol/openid-connect/token";
      userProfileURL = "https://keycloak.cmgn.io/auth/realms/master/protocol/openid-connect/userinfo";
      userProfileUsernameAttr = "preferred_username";
      userProfileDisplayNameAttr = "name";
      userProfileEmailAttr = "email";
    };
    port = 3000;
    uploadsPath = "/var/lib/codimd/uploads";
  };
in {
  users.groups.codimd = {};
  users.users.codimd = {
    description = "HedgeDoc service user";
    group = "codimd";
    extraGroups = [];
    home = "/var/lib/codimd";
    createHome = true;
    isSystemUser = true;
  };

  systemd.services.hedgedoc = {
    description = "HedgeDoc Service";
    wantedBy = [ "multi-user.target" ];
    after = [ "networking.target" ];
    serviceConfig = {
      WorkingDirectory = "/var/lib/codimd";
      ExecStart = "${pkgs.hedgedoc}/bin/hedgedoc";
      Environment = [
        "CMD_CONFIG_FILE=${prettyJSON configuration}"
          "NODE_ENV=production"
      ];
      Restart = "always";
      User = "codimd";
      PrivateTmp = true;
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
