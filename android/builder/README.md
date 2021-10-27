# android.builder.lib

## Cross-build android lineage for a set of target hardware

+ `build_image()`

### Configure
```yaml
environment:
  BUILD_DATA_VOLUME: android-build-data
  BRANCH_NAME: lineage-17.1
  DEVICE_LIST: sailfish
  SIGN_BUILDS: true
  SIGNATURE_SPOOFING: restricted
  CUSTOM_PACKAGES: |
    GmsCore GsfProxy FakeStore MozillaNlpBackend NominatimNlpBackend
    com.google.android.maps.jar FDroid FDroidPrivilegedExtension
```
