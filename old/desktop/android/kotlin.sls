{% set KOTLIN_VERSION= "1.3.61" %}

# Kotlin compiler
kotlin-compiler:
  file.managed:
    - source: https://github.com/JetBrains/kotlin/releases/download/v{{ s.KOTLIN_VERSION }}/kotlin-compiler-{{ s.KOTLIN_VERSION }}.zip
    - target: /usr/local/lib/kotlin-compiler-{{ s.KOTLIN_VERSION }}.zip
  archive.extract:
    - name: /usr/local/lib/kotlin-compiler-{{ s.KOTLIN_VERSION }}.zip
    - target: /opt/
