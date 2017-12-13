include:
  - docker

skype_container:
  cmd.run:
    - name: docker pull sameersbn/skype:latest
    - onlyif: test "$(docker images sameersbn/skype:latest)" = ""
    - require:
      - sls: docker

skype_wrapper:
  cmd.run:
    - name: docker run -it --rm --volume /usr/local/bin/:/target sameersbn/skype:latest install
    - unless: test -e /usr/local/bin/skype-wrapper


skype_desktop:
  file.managed:
    - name: /usr/share/applications/skype.desktop
    - contents: |
        [Desktop Entry]
        Encoding=UTF-8
        Type=Application
        Name=Skype
        Exec="/usr/local/bin/skype"
        Terminal=true
        Categories=Network;Application;
        Comment=binary only Skype VOIP using docker for privacy
