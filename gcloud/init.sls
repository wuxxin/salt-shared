
gcetools:
  - archive.extracted:
    - source: https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz
    - name: /srv/google-cloud-sdk
  - cmd.wait:
    - name: env CLOUDSDK_REINSTALL_COMPONENTS=pkg-core,pkg-python ./google-cloud-sdk/install.sh
    - cwd: /srv
    - watch:
      - archive: gcetools


