
plantuml:
  file.managed:
    - name: /usr/local/lib/plantuml.jar
    - source: http://tenet.dl.sourceforge.net/project/plantuml/plantuml.8038.jar
    - hash: sha256=7f204eefe286f6c941e9538affd37f657923a837ce89803b5e8fe0a65e6468ce
    - require:
      - file: plantuml_sh

plantuml_sh:
  file.managed:
    - name: /usr/local/bin/plantuml
    - mode: "0755"
    - contents: |
        #!/bin/bash
        java -jar /usr/local/lib/plantuml.jar $@
