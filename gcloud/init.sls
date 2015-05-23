
# fixme: make user default, and woraround hash by downloading manual
gcetools:
  archive.extracted:
    - source: https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz
    - source_hash: sha256=e7d972569f74028faf1c64d2e389f61a6656390c4bf91dc79afd81f567eec9f4
    - name: /srv/
    - archive_format: tar
    - if_missing: /srv/google-cloud-sdk
  cmd.wait:
    - name: env CLOUDSDK_REINSTALL_COMPONENTS=pkg-core,pkg-python ./google-cloud-sdk/install.sh
    - cwd: /srv
    - watch:
      - archive: gcetools


