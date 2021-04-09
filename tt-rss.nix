{ config, pkgs, ... }:

{
  services.tt-rss = {
    enable = true;
    selfUrlPath = "https://rss.cmgn.io/";
    virtualHost = null;
    pool = "rss";
    database = {
      passwordFile = "/var/secrets/tt-rss/database_password";
    };
    themePackages = [ pkgs.tt-rss-theme-feedly ];
    pluginPackages = [ pkgs.tt-rss-plugin-auth-ldap ];
    plugins = [ "auth_ldap" ];
    extraConfig = ''
      define('LDAP_AUTH_SERVER_URI', 'ldap://localhost:389/');
      define('LDAP_AUTH_USETLS', FALSE);
      define('LDAP_AUTH_BASEDN', 'ou=users,dc=cmgn,dc=io');
      define('LDAP_AUTH_ANONYMOUSBEFOREBIND', TRUE);
      define('LDAP_AUTH_SEARCHFILTER', '(uid=???)');
      define('LDAP_AUTH_LOGIN_ATTRIB', 'uid');
      define('LDAP_AUTH_LOG_ATTEMPTS', TRUE);
      define('LDAP_AUTH_DEBUG', TRUE);
    '';
  };

  services.phpfpm.pools = {
    ${config.services.tt-rss.pool} = {
      user = "tt_rss";
      settings = {
        "listen.owner" = "caddy";
        "listen.group" = "caddy";
        "listen.mode" = "0600";
        "pm" = "dynamic";
        "pm.max_children" = 75;
        "pm.start_servers" = 10;
        "pm.min_spare_servers" = 5;
        "pm.max_spare_servers" = 20;
        "pm.max_requests" = 500;
        "catch_workers_output" = 1;
      };
    };
  };
}
