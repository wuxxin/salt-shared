apport:
  service.dead:
    - name: apport
    - enable: false
apport_masked:
  service.masked:
    - name: apport

whoopsie:
  service.dead:
    - name: whoopsie
    - enable: false
whoopsie_masked:
  service.masked:
    - name: whoopsie

# XXX remove binary and replace with alternatives link to /dev/null, so it wont be overwritten, and cron.daily/popularity-contest will exit and not run popularity-contest
remove_popularity-contest-binary:
  cmd.run:
    - name: update-alternatives --force --install /usr/sbin/popularity-contest popularity-contest /dev/null 50
    - onlyif: test -f /usr/sbin/popularity-contest
