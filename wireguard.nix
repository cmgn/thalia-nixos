{ ... }:
let
  port = 51900;
in {
  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "10.0.0.1/24" ];
      listenPort = port;
      privateKeyFile = "/var/secrets/wireguard/wg0/private";
      peers = [
        {
          publicKey = "tS+X6wRVQwQ7ATErSx4ceSkXmrCPCR0mBp96Kew+lkM=";
          allowedIPs = [ "10.0.0.2/32" ];
        }
      ];
    };
  };

  networking.firewall.allowedUDPPorts = [ port ];
}
