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

  users.users.guest = {
    createHome = true;
    isNormalUser = true;
    # shell = "/bin/false";
    # extraGroups = [];
    group = "users";
    home = "/home/guest";
    uid = 1001;
    hashedPassword = "$6$OP33w4bfcdfSUCad$dgiWD.4uPeZNF2QyCCjg37Jg/07gF38/9w2iNyiYKspCe6hJo1QpCoGDvHcO1MuGLyiuHeiC5KUExQqz/fReT0";
  };

  users.users.guest.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCul+ZtHNvUVFR+0BhcndEgVc5f0mQiZqb3Ic3/wCfrS7UpbrHc4a4uKIWjTYCybyTAZnwBK1B2C4rdXu7se+vAKotXXBd2sqLq5lDujTIyXUvu7wdaR0iz1j5nD+mTDLyNUmG4IRmLean2+50KhS2pqkFQMXhhz2LQ5Pcv+016kmlguxvbWvUm5HUmrghNtRTPnlNMJ3CIphSSPbdZPx0mbdwhrDPsE0Emh+/4o1YFbfcGsKbvV20D1T/FKSoaffkLvLhIy/SyVittcNsgPEvqiP5qe5DQoxsai86AX14AnEHGpxWL8QvaWiF4RGcRX3ckx8wsq2J23dsE/PN4TCg/lNB8EOpb8U3CCWjBJKN+7eiHqHvUe0noZZZnaUgHiY1YR7mQtfpPK5oxaPuQC3qlSIy3o/BFV0Ed+73Sfd2TcGEUp/d3CmuivHn3vbaacMnKsn1q2t7zZdrMs56e+fpzx3jfC0zr4e2VBjZ1VBuOdpK89MDgR9bpbQtxTSvl/LE= ryan@nixos" 
  ];

  networking.firewall.allowedUDPPorts = [ 60001 ];
  networking.firewall.allowedTCPPorts = [
    80
    443
    6443 # This is required so that pod can reach the API server (running on port 6443 by default)
  ];

  services.k3s.enable = true;
  services.k3s.role = "server";
  services.k3s.extraFlags = toString [
    # "--kubelet-arg=v=4" # Optionally add additional args to k3s
    "--write-kubeconfig-mode 644 --disable traefik"
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

    port_in_redirect off;

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

    upstream ssh {
        server 127.0.0.1:3100;
        server 127.0.0.1:4100 backup;
    }

    upstream ssha {
      server 127.0.0.1:3101;
      server 127.0.0.1:4101 backup;
    }

    upstream ssh2 {
      server 127.0.0.1:3102;
      server 127.0.0.1:4102 backup;
    }

    upstream ssh3 {
      server 127.0.0.1:3103;
      server 127.0.0.1:4103 backup;
    }

    upstream ssh4 {
      server 127.0.0.1:3104;
      server 127.0.0.1:4104 backup;
    }

    upstream ssh5 {
      server 127.0.0.1:3105;
      server 127.0.0.1:4105 backup;
    }

    upstream ssh6 {
      server 127.0.0.1:3106;
      server 127.0.0.1:4106 backup;
    }

    upstream ssh7 {
      server 127.0.0.1:3107;
      server 127.0.0.1:4107 backup;
    }

    upstream ssh8 {
      server 127.0.0.1:3108;
      server 127.0.0.1:4108 backup;
    }

    upstream ssh9 {
      server 127.0.0.1:3109;
      server 127.0.0.1:4109 backup;
    }

    upstream ssh10 {
      server 127.0.0.1:3110;
      server 127.0.0.1:4110 backup;
    }

    upstream ssh11 {
      server 127.0.0.1:3111;
      server 127.0.0.1:4111 backup;
    }

    upstream ssh12 {
      server 127.0.0.1:3112;
      server 127.0.0.1:4112 backup;
    }

    upstream ssh13 {
      server 127.0.0.1:3113;
      server 127.0.0.1:4113 backup;
    }

    upstream ssh14 {
      server 127.0.0.1:3114;
      server 127.0.0.1:4114 backup;
    }

    upstream ssh15 {
      server 127.0.0.1:3115;
      server 127.0.0.1:4115 backup;
    }

    upstream ssh16 {
      server 127.0.0.1:3116;
      server 127.0.0.1:4116 backup;
    }

    upstream ssh17 {
      server 127.0.0.1:3117;
      server 127.0.0.1:4117 backup;
    }

    upstream ssh18 {
      server 127.0.0.1:3118;
      server 127.0.0.1:4118 backup;
    }

    upstream ssh19 {
      server 127.0.0.1:3119;
      server 127.0.0.1:4119 backup;
    }

    upstream ssh20 {
      server 127.0.0.1:3120;
      server 127.0.0.1:4120 backup;
    }

    '';

    virtualHosts = {
      "codinghermit.net" = {
        http2 = true;
        enableACME = true;
        forceSSL = true;

        locations."/dev" = {
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

        locations."/site".extraConfig = ''
          return 301 /;
        '';

        # locations."~ \.css".extraConfig = ''
        #   add_header  Content-Type    text/css;
        # '';
        # locations."~ \.js".extraConfig = ''
        #   add_header  Content-Type    application/x-javascript;
        # '';

        locations."/" = {
          proxyPass = "http://ssh";
          extraConfig = ''
            etag on;
            gzip on;

            # Route support
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

            client_max_body_size 16m;
          '';
        };

        locations."/ssha" = {
          proxyPass = "http://ssha";
          extraConfig = ''
            proxy_set_header X-Forwarded-Host $host:$server_port;
            proxy_set_header X-Forwarded-Server $host;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

            # rewrite /ssh1(/.*|$) /$1 break;
            # proxy_redirect     off;
            # proxy_set_header   Host $host;

            # etag on;
            # gzip on;

            # Route support
            # rewrite ^/ssh1(.*)$ $1 break;
            # proxy_set_header Host $host;
            # proxy_set_header X-Real-IP $remote_addr;
            # proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

            # client_max_body_size 16m;

            # proxy_read_timeout 240;
            # proxy_redirect off;
            # proxy_buffering off;
            # proxy_set_header Host $host;
            # proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            # proxy_set_header X-Forwarded-Proto https;
          '';
        };

        locations."/ssh2/" = {
          proxyPass = "http://ssh2/";
          extraConfig = ''
            etag on;
            gzip on;

            # Route support
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

            client_max_body_size 16m;
          '';
        };

        locations."/ssh3/" = {
          proxyPass = "http://ssh3/";
          extraConfig = ''
            etag on;
            gzip on;

            # Route support
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

            client_max_body_size 16m;
          '';
        };

        locations."/ssh4/" = {
          proxyPass = "http://ssh4/";
          extraConfig = ''
            etag on;
            gzip on;

            # Route support
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

            client_max_body_size 16m;
          '';
        };

        locations."/ssh5/" = {
          proxyPass = "http://ssh5/";
          extraConfig = ''
            etag on;
            gzip on;

            # Route support
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

            client_max_body_size 16m;
          '';
        };

        locations."/ssh6/" = {
          proxyPass = "http://ssh6/";
          extraConfig = ''
            etag on;
            gzip on;

            # Route support
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

            client_max_body_size 16m;
          '';
        };

        locations."/ssh7/" = {
          proxyPass = "http://ssh7/";
          extraConfig = ''
            etag on;
            gzip on;

            # Route support
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

            client_max_body_size 16m;
          '';
        };

        locations."/ssh8/" = {
          proxyPass = "http://ssh8/";
          extraConfig = ''
            etag on;
            gzip on;

            # Route support
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

            client_max_body_size 16m;
          '';
        };

        locations."/ssh9/" = {
          proxyPass = "http://ssh9/";
          extraConfig = ''
            etag on;
            gzip on;

            # Route support
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

            client_max_body_size 16m;
          '';
        };

        locations."/ssh10/" = {
          proxyPass = "http://ssh10/";
          extraConfig = ''
            etag on;
            gzip on;

            # Route support
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

            client_max_body_size 16m;
          '';
        };

        locations."/ssh11/" = {
          proxyPass = "http://ssh11/";
          extraConfig = ''
            etag on;
            gzip on;

            # Route support
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

            client_max_body_size 16m;
          '';
        };

        locations."/ssh12/" = {
          proxyPass = "http://ssh12/";
          extraConfig = ''
            etag on;
            gzip on;

            # Route support
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

            client_max_body_size 16m;
          '';
        };

        locations."/ssh13/" = {
          proxyPass = "http://ssh13/";
          extraConfig = ''
            etag on;
            gzip on;

            # Route support
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

            client_max_body_size 16m;
          '';
        };

        locations."/ssh14/" = {
          proxyPass = "http://ssh14/";
          extraConfig = ''
            etag on;
            gzip on;

            # Route support
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

            client_max_body_size 16m;
          '';
        };

        locations."/ssh15/" = {
          proxyPass = "http://ssh15/";
          extraConfig = ''
            etag on;
            gzip on;

            # Route support
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

            client_max_body_size 16m;
          '';
        };

        locations."/ssh16/" = {
          proxyPass = "http://ssh16/";
          extraConfig = ''
            etag on;
            gzip on;

            # Route support
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

            client_max_body_size 16m;
          '';
        };

        locations."/ssh17/" = {
          proxyPass = "http://ssh17/";
          extraConfig = ''
            etag on;
            gzip on;

            # Route support
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

            client_max_body_size 16m;
          '';
        };

        locations."/ssh18/" = {
          proxyPass = "http://ssh18/";
          extraConfig = ''
            etag on;
            gzip on;

            # Route support
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

            client_max_body_size 16m;
          '';
        };

        locations."/ssh19/" = {
          proxyPass = "http://ssh19/";
          extraConfig = ''
            etag on;
            gzip on;

            # Route support
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

            client_max_body_size 16m;
          '';
        };

        locations."/ssh20/" = {
          proxyPass = "http://ssh20/";
          extraConfig = ''
            etag on;
            gzip on;

            # Route support
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

            client_max_body_size 16m;
          '';
        };

        # locations."/" = {
        #   proxyPass = "http://frontend";
        #   extraConfig = ''

        #   proxy_pass_header Content-Type;

        #   proxy_redirect                      off;
        #   proxy_set_header Host               $host;
        #   proxy_set_header X-Real-IP          $remote_addr;
        #   proxy_set_header X-Forwarded-For    $proxy_add_x_forwarded_for;
        #   proxy_set_header X-Forwarded-Proto  $scheme;
        #   proxy_read_timeout          1m;
        #   proxy_connect_timeout       1m;


        #   # add_header 'Access-Control-Allow-Origin' '*' always;

        #   # add_header X-Content-Type-Options nosniff;

        #   # proxy_http_version 1.1;
        #   # proxy_set_header Upgrade $http_upgrade;
        #   # proxy_set_header Connection "upgrade";
        #   # proxy_set_header Host $host;
        #   # proxy_set_header X-Real-IP $remote_addr;
        #   # proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        #   # proxy_set_header X-Forwarded-Proto $scheme;
        #   # proxy_set_header X-Forwarded-Host $host;
        #   # proxy_set_header X-Forwarded-Port $server_port;

        #   # allow all;
        #   # add_header  Content-Type    application/x-javascript;
        #   # add_header  Content-Type    text/css;
        #   # add_header  Content-Type    text/html;

        #   # etag on;
        #   # gzip on;

        #   # Route support
        #   # proxy_set_header X-Real-IP $remote_addr;
        #   # proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        #   # Enable SharedArrayBuffer
        #   # add_header 'Cross-Origin-Embedder-Policy' 'require-corp' always;
        #   # add_header 'Cross-Origin-Opener-Policy' 'same-origin' always;

        #   # add_header 'Access-Control-Allow-Origin' '*' always;
        #   # add_header 'Access-Control-Allow-Methods' 'POST, PUT, DELETE, GET, PATCH, OPTIONS' always;
        #   # add_header 'Access-Control-Allow-Headers' 'Authorization, Content-Type, Idempotency-Key' always;
        #   # add_header 'Access-Control-Expose-Headers' 'Link, X-RateLimit-Reset, X-RateLimit-Limit, X-RateLimit-Remaining, X-Request-Id' always;
        #   # if ($request_method = OPTIONS) {
        #   #   return 204;
        #   # }

        #   # add_header X-XSS-Protection "1; mode=block";
        #   # add_header X-Permitted-Cross-Domain-Policies none;
        #   # add_header X-Frame-Options DENY;
        #   # add_header X-Content-Type-Options nosniff;
        #   # add_header Referrer-Policy same-origin;
        #   # add_header X-Download-Options noopen;
        #   # proxy_http_version 1.1;
        #   # proxy_set_header Upgrade $http_upgrade;
        #   # proxy_set_header Connection "upgrade";
        #   # proxy_set_header Host $host;

        #   # client_max_body_size 16m;

        #   '';
        # };

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

        # locations."/" = {
        #   proxyPass = "http://ssh/";
        #   extraConfig = ''
        #     etag on;
        #     gzip on;

        #     # Route support
        #     proxy_set_header X-Real-IP $remote_addr;
        #     proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        #     client_max_body_size 16m;
        #   '';
        # };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    # Sys utils
    mosh btop git openssl gnumake bat
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
    # Ops
    k3s
  ];

  system.stateVersion = "21.11";
}
