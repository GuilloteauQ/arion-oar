{ pkgs, lib,... }:
let

  inherit (import ../common/ssh-keys.nix pkgs) snakeOilPrivateKey snakeOilPublicKey;

common = {
  
  service.volumes = [ "${builtins.getEnv "PWD"}/..:/srv" ];
  service.capabilities = { SYS_ADMIN = true; }; # for nfs
  service.useHostStore = true;
  
  nixos.useSystemd = true;
  nixos.runWrappersUnsafe = true;
  nixos.configuration = {
    networking.firewall.enable = false;
    boot.tmpOnTmpfs = true;

    users.users.user1 = {isNormalUser = true;};
    users.users.user2 = {isNormalUser = true;};
    
    environment.systemPackages = with pkgs; [ nfs-utils socat wget ruby openssh ];
    imports = lib.attrValues pkgs.nur.repos.kapack.modules;
    
    # oar user's key files
    environment.etc."privkey.snakeoil" = { mode = "0600"; source = snakeOilPrivateKey; };
    environment.etc."pubkey.snakeoil" = { mode = "0600"; source = snakeOilPublicKey; };

    services.oar = {
      # oar db passwords
      database = {
        host = "server";
        passwordFile = "/srv/common/oar-dbpassword";
      };
      server.host = "server";
      privateKeyFile = "/etc/privkey.snakeoil";
      publicKeyFile = "/etc/pubkey.snakeoil";
    };  
    
  };

};

addCommon = x: lib.recursiveUpdate x common;

 apacheHttpdWithIdent = pkgs.apacheHttpd.overrideAttrs (oldAttrs: rec {
  configureFlags = oldAttrs.configureFlags ++ [ "--enable-ident" ]; });

  defineNode = name: resources:
    addCommon {
      service.hostname=name;
      nixos.configuration = {
        services.oar.node = {
          enable = true;
          register = {
            enable = true;
            extraCommand = ''
              /srv/common/prepare_oar_cgroup.sh init
              mkdir -p /mnt/shared
              /run/current-system/sw/bin/mount -t nfs fileserver:/srv/shared /mnt/shared -o nolock
            '';
            nbResources = resources;
          };
        };
      };
    };
in

{  
  services.cigri = addCommon {
    service.hostname="cigri";
    nixos.configuration = {
      services.cigri = {
        dbserver.enable = true;
        client.enable = true;
        database = {
          host = "cigri";
          passwordFile = "/srv/common/cigri-dbpassword";
        };
        server = {
          enable = true;
          web.enable = true;
          host = "cigri";
          logfile = "/tmp/cigri.log";
        };        
      };
      services.my-startup = {
        enable = true;
        path = with pkgs; [ nur.repos.kapack.cigri sudo postgresql ];
        script = ''
          # Waiting cigri database is ready
          until pg_isready -h cigri -p 5432 -U postgres
          do
            echo "Waiting for postgres"
            sleep 0.5;
          done

          until sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -qw cigri
          do
            echo "Waiting for cigri db created"
            sleep 0.5
          done

          newcluster cluster_0  http://server/oarapi-unsecure/ none fakeuser fakepasswd "" server oar2_5 resource_id 2 ""
          systemctl restart cigri-server
        '';
      };
    }; 
  };

  services.frontend = addCommon {
    service.hostname="frontend";
    nixos.configuration = {
      services.oar.client.enable = true;
    };    
  };

  services.server = addCommon {
    service.hostname="server";
    nixos.configuration = {
      environment.etc."oar/api-users" = {
        mode = "0644";
        text = ''
          user1:$apr1$yWaXLHPA$CeVYWXBqpPdN78e5FvbY3/
          user2:$apr1$qMikYseG$VL8nyeSSmxXNe3YDOiCwr1
        '';
      };
      services.oar.dbserver.enable = true;
      services.oar.server = {
        enable = true;
      };
      
      services.oar.web = {
        enable = true;
        extraConfig = ''
          #To support remote_ident custom header
          underscores_in_headers on;
          location ^~ /oarapi-unsecure/ {
            rewrite ^/oarapi-unsecure/?(.*)$ /$1 break;
            include ${pkgs.nginx}/conf/uwsgi_params;
            uwsgi_pass unix:/run/uwsgi/oarapi.sock;
          }
        '';
      };
    };
  };

  services.fileserver = addCommon {
    service.hostname="fileserver";
    nixos.configuration = {
      services.nfs.server.enable = true;
      # services.nfs.server.exports = ''/srv/shared *(rw,sync,no_subtree_check,no_root_squash,insecure)'';
      # services.nfs.server.exports = ''/srv/shared *(rw,sync,no_subtree_check,no_root_squash,insecure)'';
      services.nfs.server.exports = ''/srv/shared *(rw,no_subtree_check,no_root_squash)'';
    };    
  };
  

  services.node1 = defineNode "node1" "100";
}

