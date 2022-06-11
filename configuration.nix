{ pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
  ];

  boot.cleanTmpDir = true;
  zramSwap.enable = true;
  networking.hostName = "vmi804767";
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCul+ZtHNvUVFR+0BhcndEgVc5f0mQiZqb3Ic3/wCfrS7UpbrHc4a4uKIWjTYCybyTAZnwBK1B2C4rdXu7se+vAKotXXBd2sqLq5lDujTIyXUvu7wdaR0iz1j5nD+mTDLyNUmG4IRmLean2+50KhS2pqkFQMXhhz2LQ5Pcv+016kmlguxvbWvUm5HUmrghNtRTPnlNMJ3CIphSSPbdZPx0mbdwhrDPsE0Emh+/4o1YFbfcGsKbvV20D1T/FKSoaffkLvLhIy/SyVittcNsgPEvqiP5qe5DQoxsai86AX14AnEHGpxWL8QvaWiF4RGcRX3ckx8wsq2J23dsE/PN4TCg/lNB8EOpb8U3CCWjBJKN+7eiHqHvUe0noZZZnaUgHiY1YR7mQtfpPK5oxaPuQC3qlSIy3o/BFV0Ed+73Sfd2TcGEUp/d3CmuivHn3vbaacMnKsn1q2t7zZdrMs56e+fpzx3jfC0zr4e2VBjZ1VBuOdpK89MDgR9bpbQtxTSvl/LE= ryan@nixos" 
  ];

  # Custom stuff
  users.users.admin = {
    createHome = true;
    isNormalUser = true;
    extraGroups = [
      "wheel"
    ];
    group = "users";
    home = "/home/admin";
    uid = 1000;
  };

  users.users.admin.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCul+ZtHNvUVFR+0BhcndEgVc5f0mQiZqb3Ic3/wCfrS7UpbrHc4a4uKIWjTYCybyTAZnwBK1B2C4rdXu7se+vAKotXXBd2sqLq5lDujTIyXUvu7wdaR0iz1j5nD+mTDLyNUmG4IRmLean2+50KhS2pqkFQMXhhz2LQ5Pcv+016kmlguxvbWvUm5HUmrghNtRTPnlNMJ3CIphSSPbdZPx0mbdwhrDPsE0Emh+/4o1YFbfcGsKbvV20D1T/FKSoaffkLvLhIy/SyVittcNsgPEvqiP5qe5DQoxsai86AX14AnEHGpxWL8QvaWiF4RGcRX3ckx8wsq2J23dsE/PN4TCg/lNB8EOpb8U3CCWjBJKN+7eiHqHvUe0noZZZnaUgHiY1YR7mQtfpPK5oxaPuQC3qlSIy3o/BFV0Ed+73Sfd2TcGEUp/d3CmuivHn3vbaacMnKsn1q2t7zZdrMs56e+fpzx3jfC0zr4e2VBjZ1VBuOdpK89MDgR9bpbQtxTSvl/LE= ryan@nixos" 
  ];

  networking.firewall.allowedUDPPorts = [ 60001 ];
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  security.acme = {
    email = "ryancargan@gmail.com";
    acceptTerms = true;
  };

  services.nginx = {
    enable = true;
    #addSSL = true;

    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;

    recommendedProxySettings = true;

    commonHttpConfig = ''
    upstream frontend {
         server 127.0.0.1:3000;
         server 127.0.0.1:3010 backup;
    }
    upstream backend {
	server 127.0.0.1:4000;
	server 127.0.0.1:4010 backup;
    }
#    location @fallback {
#      root /var/www/static;
#      try_files $uri =404;
#    }
    '';

    virtualHosts = {
      "codinghermit.net" = {
        http2 = true;
        enableACME = true;
        forceSSL = true;

#	locations."@fallback" = {
#	  root = "/var/www/static";
#	  tryFiles = "$uri =404";
#	};

        locations."/" = {
          proxyPass = "http://frontend";
          extraConfig = ''

#          location @fallback {
#            root /var/www/static;
#            try_files $uri =404;
#          }

#	  proxy_intercept_errors on;
#	  error_page 404 = @fallback;

          etag on;
          gzip on;

	  add_header 'Cross-Origin-Embedder-Policy' 'require-corp' always;
	  add_header 'Cross-Origin-Opener-Policy' 'same-origin' always;

          add_header 'Access-Control-Allow-Origin' '*' always;
          add_header 'Access-Control-Allow-Methods' 'POST, PUT, DELETE, GET, PATCH, OPTIONS' always;
          add_header 'Access-Control-Allow-Headers' 'Authorization, Content-Type, Idempotency-Key' always;
          add_header 'Access-Control-Expose-Headers' 'Link, X-RateLimit-Reset, X-RateLimit-Limit, X-RateLimit-Remaining, X-Request-Id' always;
          if ($request_method = OPTIONS) {
            return 204;
          }

          add_header X-XSS-Protection "1; mode=block";
          add_header X-Permitted-Cross-Domain-Policies none;
          add_header X-Frame-Options DENY;
          add_header X-Content-Type-Options nosniff;
          add_header Referrer-Policy same-origin;
          add_header X-Download-Options noopen;
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "upgrade";
          proxy_set_header Host $host;

          client_max_body_size 16m;

          '';
        };
      };
    };
  };

#   security.acme.acceptTerms = true;
#   #security.acme.email = "ryancargan@gmail.com";
#   security.acme.certs."codinghermit.net" = {
#     #webroot = "/var/lib/acme/.challenges";
#     email = "ryancargan@gmail.com";
#     group = "nginx";
#     #extraDomainNames = [ "mail.example.com" ];
#   };

#   users.users.nginx.extraGroups = [ "acme" ];
  
#   services.nginx = {
#     enable = true;
#     recommendedProxySettings = true;
#     recommendedTlsSettings = true;
#     # other Nginx options
# #    upstreams = {
# #      "frontend" = {
# #        servers = { "127.0.0.1:3000" = {}; };
# #      };
#     #    };
#     commonHttpConfig = ''
#     upstream node_frontend {
#              server 127.0.0.1:3000;
#     }
#     upstream go_backend {
#              server 127.0.0.1:3001;
#     }
#     upstream python_api {
#              server 127.0.0.1:3002;
#     }
#     upstream deno_frontend
#              server 127.0.0.1:3003;
#     '';
#     virtualHosts."codinghermit.net" =  {
#       enableACME = true;
#       forceSSL = true;
#       #serverAliases = [ "*.codinghermit.xyz" ];
#       #locations."/.well-known/acme-challenge" = {
#       #  root = "/var/lib/acme/acme-challenge";
#       #};
#       #root = "/home/admin/workspace/monorepo/projects/react-app/dist";
#       #index = "index.html";
#       locations."/" = {
#         #extraConfig = ''
#         #try_files /maintenance.html @proxy;
#         #location @proxy {
#         #  proxy_pass http://127.0.0.1:3000;
#         #}
#         #'';
#         extraConfig = ''
#         # proxy_pass http://frontend;
#         root /var/www/static;
#         index index.html;
#         '';
#         #proxyPass = "http://127.0.0.1:3000";
#         #proxyPass = "http://localhost:3000";
#         #proxy_pass = http://frontend;
#         #return = "301 https://$host$request_uri";
#         #proxyPass = "http://localhost:3000";
#         #proxyWebsockets = true; # needed if you need to use WebSocket
#         #extraConfig =
#           # required when the target is also TLS server with multiple hosts
#           #"proxy_ssl_server_name on;" +
#           # required when the server wants to use HTTP Authentication
#           #"proxy_pass_header Authorization;"
#         #;[
#       };
#       locations."/dev" ={
#         extraConfig = ''
#         proxy_pass http://node_frontend;
#         '';
#       };
#       locations."/api" ={
#         extraConfig = ''
#         proxy_pass http://go_backend;
#         '';
#       };
#       locations."/ml" ={
#         extraConfig = ''
#         proxy_pass http://python_api;
#         '';
#       };
#       locations."/lite" ={
#         extraConfig = ''
#         proxy_pass http://deno_frontend;
#         '';
#       };
#       #locations."@proxy" = {
#        # proxyPass = "http://127.0.0.1:3000";
#       #};
#     };
#   };

  # systemd.services.daemon-server-node-dev = {
  #   description = "node dev server to pass to reverse proxy in background";
  #   enable = false;
  #   wantedBy = [ "multi-user.target" ];
  #   after = [ "network.target" ];
  #   serviceConfig = {
  #     Type = "exec";
  #     User = "admin";
  #     ExecStart = "${pkgs.nodePackages.pnpm}/bin/pnpm dev --prefix=/home/admin/workspace/monorepo/projects/react-app/";
  #   };
  # };
  # systemd.services.daemon-server-node-preview = {
  #   description = "node preview server to pass to reverse proxy in background";
  #   enable = true;
  #   wantedBy = [ "multi-user.target" ];
  #   after = [ "network.target" ];
  #   serviceConfig = {
  #     Type = "exec";
  #     User = "admin";
  #     ExecStart = "${pkgs.nodePackages.pnpm}/bin/pnpm preview --prefix=/home/admin/workspace/monorepo/projects/react-app/";
  #   };
  # };

  environment.systemPackages = with pkgs; [
    mosh btop neovim deno git nodePackages.pnpm openssl rustup
  ];
}
