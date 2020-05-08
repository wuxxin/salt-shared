include:
  - .init


recoll_server:
  user.present:
    - name: recoll
  group.present:
    - name: recoll
  git.latest:
    source: https://github.com/koniu/recoll-webui.git
    target: /home/recoll/recoll-webui
