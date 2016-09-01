
plantuml:
  file.managed:
    - name: /usr/local/lib/plantuml.jar
    - source: http://tenet.dl.sourceforge.net/project/plantuml/plantuml.8042.jar
    - hash: sha256=0d7119e965d0502d7a743c84412aee7b1050db0471b3ebb8e1b0c5c48064e680
    - require:
      - file: plantuml_sh

plantuml_sh:
  file.managed:
    - name: /usr/local/bin/plantuml
    - mode: "0755"
    - contents: |
        #!/bin/bash
        java -jar /usr/local/lib/plantuml.jar $@
