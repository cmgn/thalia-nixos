{ config, pkgs, ... }:
let
  promtailConfig = pkgs.writeText "promtail-config.yml" ''
  server:
    http_listen_port: 28183
    grpc_listen_port: 0
  
  positions:
    filename: /tmp/positions.yaml
  
  clients:
    - url: http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}/loki/api/v1/push
  
  scrape_configs:
    - job_name: journal
      journal:
        max_age: 12h
        labels:
          job: systemd-journal
          host: chrysalis
      relabel_configs:
        - source_labels: ['__journal__systemd_unit']
          target_label: 'unit'
    '';
  ldapConfig = pkgs.writeText "ldap.toml" ''
    [[servers]]
    host = "localhost"
    port = 389
    bind_dn = "cn=root,dc=cmgn,dc=io"
    bind_password = "${builtins.readFile "/var/secrets/ldap/password"}"
    search_filter = "(cn=%s)"
    search_base_dns = ["ou=users,dc=cmgn,dc=io"]
  '';
in {
  services.grafana = {
    enable = true;
    domain = "grafana.cmgn.io";
    port = 2342;
    addr = "127.0.0.1";
    extraOptions = {
      AUTH_LDAP_ENABLED = "true";
      AUTH_LDAP_CONFIG_FILE = ldapConfig;
      AUTH_LDAP_ALLOW_SIGN_UP = "true";
    };
  };

  services.prometheus = {
    enable = true;
    port = 9001;

    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port= 9002;
      };
    };

    scrapeConfigs = [
      {
        job_name = "thalia";
        static_configs = [{
          targets = [
            "127.0.0.1:${toString config.services.prometheus.exporters.node.port}"
          ];
        }];
      }
    ];
  };

  services.loki = let
    dataDir = "/var/db/loki";
  in {
    enable = true;
    configuration = {
      auth_enabled = false;

      server = {
        http_listen_port = 3100;
      };

      ingester = {
        lifecycler = {
          address = "127.0.0.1";
          ring = {
            kvstore = {
              store =  "inmemory";
            };
            replication_factor = 1;
          };
          final_sleep = "0s";
        };
        chunk_idle_period = "5m";
        chunk_retain_period = "30s";
      };

      schema_config = {
        configs = [{
          from = "2018-04-15";
          store = "boltdb";
          object_store = "filesystem";
          schema = "v9";
          index = {
            prefix = "index_";
            period = "168h";
          };
        }];
      };

      storage_config = {
        boltdb = {
          directory = "${dataDir}/index";
        };
        filesystem = {
          directory = "${dataDir}/chunks";
        };
      };

      limits_config = {
        enforce_metric_name = false;
        reject_old_samples = true;
        reject_old_samples_max_age = "168h";
      };

      chunk_store_config = {
        max_look_back_period = 0;
      };

      table_manager = {
        chunk_tables_provisioning = {
          inactive_read_throughput = 0;
          inactive_write_throughput = 0;
          provisioned_read_throughput = 0;
          provisioned_write_throughput = 0;
        };

        index_tables_provisioning = {
          inactive_read_throughput = 0;
          inactive_write_throughput = 0;
          provisioned_read_throughput = 0;
          provisioned_write_throughput = 0;
        };

        retention_deletes_enabled = false;
        retention_period = 0;
      };
    };
  };

  systemd.services.promtail = {
    description = "Promtail service for Loki";
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = ''
        ${pkgs.grafana-loki}/bin/promtail --config.file ${promtailConfig}
      '';
    };
  };
}
