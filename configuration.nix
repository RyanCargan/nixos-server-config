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
    defaults.email = "ryancargan@gmail.com";
    acceptTerms = true;
  };

  services.nginx = {
    enable = true;

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

    upstream wsbackend {
      server 127.0.0.1:4001;
      server 127.0.0.1:4011 backup;

      # proxy_read_timeout 3600;
      # proxy_connect_timeout 3600;
      # proxy_send_timeout 3600;
    }

    upstream ci {
      server 127.0.0.1:5000;
      server 127.0.0.1:5010 backup;
    }

    '';

    virtualHosts = {
      "codinghermit.net" = {
        http2 = true;
        enableACME = true;
        forceSSL = true;

        locations."/" = {
          root = "/var/www/static";
          tryFiles = "$uri /index.html";
          extraConfig = ''

          etag on;
          gzip on;

          # Routing fix
          # if (!-e $request_filename){
          #   rewrite ^(.*)$ /index.html break;
          # }

          # Enable SharedArrayBuffer
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

        locations."/dev" = {
          proxyPass = "http://frontend";
          extraConfig = ''

          allow all;

          etag on;
          gzip on;

          # Enable SharedArrayBuffer
          add_header 'Cross-Origin-Embedder-Policy' 'require-corp' always;
          add_header 'Cross-Origin-Opener-Policy' 'same-origin' always;

          add_header 'Access-Control-Allow-Origin' '*' always;
          add_header 'Access-Control-Allow-Methods' 'POST, PUT, DELETE, GET, PATCH, OPTIONS' always;
          add_header 'Access-Control-Allow-Headers' 'Authorization, Content-Type, Idempotency-Key' always;
          add_header 'Access-Control-Expose-Headers' 'Link, X-RateLimit-Reset, X-RateLimit-Limit, X-RateLimit-Remaining, X-Request-Id' always;
          if ($request_method = OPTIONS) {
            return 204;
          }

          # add_header X-XSS-Protection "1; mode=block";
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

        locations."/api/" = {
          proxyPass = "http://backend/";
          extraConfig = ''

          etag on;
          gzip on;

          # Route support
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

          client_max_body_size 16m;

          '';
        };

        locations."/socketapi/" = {
          proxyPass = "http://wsbackend/";
          proxyWebsockets = true;
          extraConfig = ''
          '';
        };

        locations."/ci" = {
          proxyPass = "http://ci";
          extraConfig = ''

          etag on;
          gzip on;

          # Enable SharedArrayBuffer
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

  environment.systemPackages = with pkgs; [
    # Sys utils
    mosh btop git openssl gnumake
    # Editors
    neovim
    # Node packages
    nodejs nodePackages.pnpm nodePackages.pm2
    # Golang
    go_1_18
    # Deno
    deno
    # Rust utils
    rustup
  ];

  system.stateVersion = "21.11";
}
