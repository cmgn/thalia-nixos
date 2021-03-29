{ config, programs, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./caddy.nix
      ./fail2ban.nix
      ./monitoring.nix
      ./wireguard.nix
      ./databases.nix
      ./keycloak.nix
      ./hedgedoc.nix
      ./ldap.nix
      ./gitea.nix
    ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "thalia";
  networking.timeServers = [ "time.google.com" ];
  networking.nameservers = [ "8.8.8.8" "8.8.4.4" ];
  networking.useDHCP = false;
  networking.defaultGateway = {
    address = "172.31.1.1";
    interface = "ens3";
  };
  networking.defaultGateway6 = {
    address = "fe80::1";
    interface = "ens3";
  };
  networking.interfaces.ens3 = {
    useDHCP = false;
    ipv4 = {
      addresses = [
        {
          address = "157.90.233.40";
          prefixLength = 32;
        }
      ];
    };
    ipv6 = {
      addresses = [
        {
          address = "2a01:4f8:1c1c:79e5::1";
          prefixLength = 64;
        }
      ];
    };
  };

  time.timeZone = "Europe/Dublin";
  i18n.defaultLocale = "en_IE.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "uk";
  };

  users.users."cmgn" = {
    createHome = true;
    extraGroups = [
      "wheel"
    ];
    group = "users";
    home = "/home/cmgn";
    shell = "${pkgs.zsh}/bin/zsh";
    uid = 1000;
  };
  users.groups."users" = {};

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    challengeResponseAuthentication = false;
    permitRootLogin = "prohibit-password";
  };
  networking.firewall.allowedTCPPorts = [ 22 ];

  services.cron.enable = true;

  system.stateVersion = "20.09";
}

