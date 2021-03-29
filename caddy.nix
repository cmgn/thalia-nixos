{ config, pkgs, ... }:

{
  services.caddy = {
    enable = true;
    config = ''
    cmgn.io {
      encode gzip
      log
      root * /srv/cmgn.io
      file_server
    }
    www.cmgn.io {
      redir https://cmgn.io{uri} permanent
    }
    grafana.cmgn.io {
      reverse_proxy 127.0.0.1:${toString config.services.grafana.port}
    }
    md.cmgn.io {
      reverse_proxy 127.0.0.1:${toString config.services.hedgedoc.configuration.port}
    }
    keycloak.cmgn.io {
      reverse_proxy 127.0.0.1:${toString config.services.keycloak.httpPort}
    }
    git.cmgn.io {
      reverse_proxy 127.0.0.1:${toString config.services.gitea.httpPort}
    }
    '';
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
