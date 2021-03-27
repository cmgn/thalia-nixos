{ config, programs, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./caddy.nix
      ./fail2ban.nix
      ./monitoring.nix
      ./wireguard.nix
    ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "thalia";
  networking.timeServers = [ "time.google.com" ];
  networking.useDHCP = false;
  networking.interfaces.ens3 = {
    useDHCP = true;
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

