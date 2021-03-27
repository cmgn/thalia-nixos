{ pkgs, config, ... }:
{
  services.postgresql = {
    enable = true;
    enableTCPIP = true;
    package = pkgs.postgresql_11;
    ensureUsers = [
      {
        name = "mimir";
        ensurePermissions = {
          "DATABASE mimir" = "ALL PRIVILEGES";
        };
      }
    ];
    ensureDatabases = [
      "mimir"
    ];
    authentication = ''
    hostnossl mimir mimir 0.0.0.0/0 md5
    '';
  };
  networking.firewall.allowedTCPPorts = [ config.services.postgresql.port ];
}
