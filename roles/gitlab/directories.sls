include:
  - .user

gitlab-data:
  file.directory:
    - name: /home/git/data
    - user: git
    - group: git
    - require:
      - user: gitlab-user

{% for a in ("backups", "uploads", "repositories", "gitlab-satellites") %}
gitlab-data-{{ a }}:
  file.directory:
    - name: /home/git/data/{{ a }}
    - user: git
    - group: git
    - require:
      - user: gitlab-user
      - file: gitlab-data
    - require_in:
      - file: gitlab-directories
{% endfor %}

gitlab-data-repositories-rights:
  cmd.run:
    - name: "chmod ug+rwX,o-rwx /home/git/data/repositories/; chmod ug-s /home/git/data/repositories/; find /home/git/data/repositories/ -type d -print0 | sudo xargs -0 chmod g+s"
    - require:
      - file: gitlab-data-repositories
    - require_in:
      - file: gitlab-directories

gitlab-data-gitlab-satellites-rights:
  cmd.run:
    - name: "chmod ug+rwX,o-rwx /home/git/data/gitlab-satellites/; chmod ug-s /home/git/data/gitlab-satellites/; find /home/git/data/gitlab-satellites/ -type d -print0 | sudo xargs -0 chmod g+s"
    - require:
      - file: gitlab-data-gitlab-satellites
    - require_in:
      - file: gitlab-directories

gitlab-data-uploads-rights:
  cmd.run:
    - name: "chmod -R u+rwX /home/git/data/uploads/"
    - require:
      - file: gitlab-data-uploads
    - require_in:
      - file: gitlab-directories

gitlab-data-ssh:
  file.directory:
    - name: /home/git/data/.ssh
    - user: git
    - group: git
    - mode: 700
    - require:
      - user: gitlab-user
      - file: gitlab-data

gitlab-directories:
  file.symlink:
    - name: /home/git/.ssh
    - target: /home/git/data/.ssh
    - require:
      - file: gitlab-data-ssh
