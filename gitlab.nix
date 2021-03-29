{ pkgs, ... }:

{
  services.gitlab = {
    enable = true;
    initialRootEmail = "services@cmgn.io";
    initialRootPasswordFile = "/var/secrets/gitlab/password";
    secrets = {
      secretFile = "/var/secrets/gitlab/secret";
      dbFile = "/var/secrets/gitlab/database";
      otpFile = "/var/secrets/gitlab/otp";
      jwsFile = "/var/secrets/gitlab/jws";
    };
    extraConfig = {
      omniauth = {
        enabled = true;
        allow_single_sign_on = ["openid_connect"];
        block_auto_created_users = false;
        providers = [
          {
            name = "openid_connect";
            label = "OpenID Connect";
            args = {
              name = "openid_connect";
              scope = ["openid" "profile"];
              response_type = "code";
              issuer = "https://keycloak.cmgn.io/auth/realms/master";
              discovery = true;
              client_auth_method = "query";
              uid_field = "preferred_username";
              client_options = {
                identifier = "gitlab";
                secret = { _secret = "/var/secrets/gitlab/openid_secret"; };
                redirect_uri = "https://git.cmgn.io/users/auth/openid_connect/callback";
              };
            };
          }
        ];
      };
    };
  };

  services.gitlab-runner = {
    enable = true;
    services = {
      # runner for building in docker via host's nix-daemon
      # nix store will be readable in runner, might be insecure
      nix = {
        # File should contain at least these two variables:
        # `CI_SERVER_URL`
        # `REGISTRATION_TOKEN`
        registrationConfigFile = "/var/secrets/gitlab/runner-registration";
        dockerImage = "alpine";
        dockerVolumes = [
          "/nix/store:/nix/store:ro"
          "/nix/var/nix/db:/nix/var/nix/db:ro"
          "/nix/var/nix/daemon-socket:/nix/var/nix/daemon-socket:ro"
        ];
        dockerDisableCache = true;
        preBuildScript = pkgs.writeScript "setup-container" ''
          mkdir -p -m 0755 /nix/var/log/nix/drvs
          mkdir -p -m 0755 /nix/var/nix/gcroots
          mkdir -p -m 0755 /nix/var/nix/profiles
          mkdir -p -m 0755 /nix/var/nix/temproots
          mkdir -p -m 0755 /nix/var/nix/userpool
          mkdir -p -m 1777 /nix/var/nix/gcroots/per-user
          mkdir -p -m 1777 /nix/var/nix/profiles/per-user
          mkdir -p -m 0755 /nix/var/nix/profiles/per-user/root
          mkdir -p -m 0700 "$HOME/.nix-defexpr"

          . ${pkgs.nix}/etc/profile.d/nix.sh

          ${pkgs.nix}/bin/nix-env -i ${builtins.concatStringsSep " " (with pkgs; [ nix cacert git openssh ])}

          ${pkgs.nix}/bin/nix-channel --add https://nixos.org/channels/nixpkgs-unstable
          ${pkgs.nix}/bin/nix-channel --update nixpkgs
        '';
        environmentVariables = {
          ENV = "/etc/profile";
          USER = "root";
          NIX_REMOTE = "daemon";
          PATH = "/nix/var/nix/profiles/default/bin:/nix/var/nix/profiles/default/sbin:/bin:/sbin:/usr/bin:/usr/sbin";
          NIX_SSL_CERT_FILE = "/nix/var/nix/profiles/default/etc/ssl/certs/ca-bundle.crt";
        };
        tagList = [ "nix" ];
      };
      # runner for building docker images
      docker-images = {
        # File should contain at least these two variables:
        # `CI_SERVER_URL`
        # `REGISTRATION_TOKEN`
        registrationConfigFile = "/var/secrets/gitlab/runner-registration";
        dockerImage = "docker:stable";
        dockerVolumes = [
          "/var/run/docker.sock:/var/run/docker.sock"
        ];
        tagList = [ "docker-images" ];
      };
      # runner for executing stuff on host system (very insecure!)
      # make sure to add required packages (including git!)
      # to `environment.systemPackages`
      shell = {
        # File should contain at least these two variables:
        # `CI_SERVER_URL`
        # `REGISTRATION_TOKEN`
        registrationConfigFile = "/var/secrets/gitlab/runner-registration";
        executor = "shell";
        tagList = [ "shell" ];
      };
      # runner for everything else
      default = {
        # File should contain at least these two variables:
        # `CI_SERVER_URL`
        # `REGISTRATION_TOKEN`
        registrationConfigFile = "/var/secrets/gitlab/runner-registration";
        dockerImage = "debian:stable";
      };
    };
  };
}
