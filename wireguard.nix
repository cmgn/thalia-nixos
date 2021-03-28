{ ... }:
let
  port = 51900;
in {
  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "10.0.0.1/24" "fe80:ffff::1/128" ];
      listenPort = port;
      privateKeyFile = "/var/secrets/wireguard/wg0/private";
      peers = [
        {
          publicKey = "tS+X6wRVQwQ7ATErSx4ceSkXmrCPCR0mBp96Kew+lkM=";
          allowedIPs = [ "10.0.0.2/32" "fe80:ffff::2/128" ];
        }
      ];
    };
  };

  networking.firewall.allowedUDPPorts = [ port ];
}
