lxd:  
  remotes:
    local:
      type: lxd
      remote_addr: localhost:8443
      cert: "/root/.config/lxc/client.crt"
      key: "/root/.config/lxc/client.key"
      verify_cert: false
      password: PaSsW0Rd
    srv02:
      type: lxd
      remote_addr: https://srv02:8443
      cert: "/root/.config/lxc/client.crt"
      key: "/root/.config/lxc/client.key"
      verify_cert: false
      password: PaSsW0Rd
  
  profiles:
    local:
      default:
        devices:
          eth0:
            nictype: bridged
            parent: lanbr0
            type: nic
      shared_mount:
        devices:
          shared_mount:
            type: "disk"
            # Source on the host
            source: "/home/shared"
            # Path in the container
            path: "home/shared"
      small:
        config:
          limits.cpu: 1
          limits.memory: 512MB
        device:
          root:
            limits.read: 20Iops
            limits.write: 10Iops
      autostart:
        config:
        - key: boot.autostart
          value: 1
        - key: boot.autostart.delay
          value: 2
        - key: boot.autostart.priority
          value: 1
  
  images:
    local:
      trusty_amd64:
        name: trusty/amd64
        source:
          name: ubuntu/trusty/amd64
          remote: images_linuxcontainers_org
        aliases:
        - trusty/amd64
        public: false
        auto_update: true
      xenial_amd64:
        name: xenial/amd64
        source:
          name: xenial/amd64
          remote: ubuntu
        aliases:
        - xenial/amd64
        public: false
        auto_update: true
  
  containers:
    local:
      aptcacher:
        running: true
        source: xenial/amd64
        profiles:
        - default
        - autostart
        devices:
          cdata:
            type: disk
            source: "/cdata/aptcacher"
            path: data
        opts:
          require:
          - lxd_profile: lxd_profile_local_default
          - lxd_profile: lxd_profile_local_autostart
          - lxd_image: lxd_image_local_xenial_amd64
      files2:
        running: true
        source: xenial/amd64
        profiles:
        - default
        - autostart
        devices:
          mntdir-cdata:
            type: disk
            source: "/cdata"
            path: cdata
          mntdir-media:
            type: disk
            source: "/media/MEDIEN"
            path: media/MEDIEN
        opts:
          require:
          - lxd_profile: lxd_profile_local_default
          - lxd_profile: lxd_profile_local_autostart
          - lxd_image: lxd_image_local_xenial_amd64
      mongo1:
        running: true
        source: xenial/amd64
        profiles:
        - default
        - autostart
        config:
        - key: security.privileged
          value: true
        devices:
          cdata:
            type: disk
            source: "/cdata/mongo1"
            path: "/data"
        opts:
          require:
          - lxd_profile: lxd_profile_local_default
          - lxd_profile: lxd_profile_local_autostart
          - lxd_image: lxd_image_local_xenial_amd64
