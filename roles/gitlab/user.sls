gitlab-user:
  group:
    - present
    - name: git
  user:
    - present
    - name: git
    - gid: git
    - home: /home/git
    - fullname: GitLab
    - require:
      - group: gitlab-user
