# android.builder

Cross-build android lineage for a set of target hardware

```yaml
environment:
  BUILD_DATA_VOLUME: android-build-data
  BRANCH_NAME: lineage-18.1
  DEVICE_LIST: sailfish
  SIGN_BUILDS: true
  SIGNATURE_SPOOFING: restricted
  CUSTOM_PACKAGES: |
    GmsCore GsfProxy FakeStore MozillaNlpBackend NominatimNlpBackend
    com.google.android.maps.jar FDroid FDroidPrivilegedExtension
```
