
plantuml:
  file.managed:
    - name: /usr/local/lib/plantuml.jar
    - source: https://netix.dl.sourceforge.net/project/plantuml/1.2017.15/plantuml.1.2017.15.jar
    - source_hash: sha256=c0bf0f8fcfa68de6cb12e8c5c67ec61efffdbfb7ea32974cb8be4a38df94a415
    - require:
      - file: plantuml_sh

plantuml_sh:
  file.managed:
    - name: /usr/local/bin/plantuml
    - mode: "0755"
    - contents: |
        #!/bin/sh
        java -jar /usr/local/lib/plantuml.jar $@
