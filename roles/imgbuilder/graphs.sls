include:
  - roles.desktop.graphics.graph

render_box:
  cmd.run:
    - name: "blockdiag -a -T pdf -f /usr/share/fonts/truetype/ttf-dejavu/DejaVuSerif.ttf box.diag"
    - cwd: this here! fixme
