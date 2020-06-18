include:
  - gnupg


# salt deploy - prepare
#######################

{#
. copy all state and pillar paths together
. generate saltmaster gpg key
. crypt saltmaster private gpg key with gpg_key of user
. add public key of saltmaster to every path where git-crypt says its working: git-crypt add-gpg-key 
. git-crypt lock on every path: git-crypt lock
. make tar.gz out of temporary dir (without parents) and save it under target_preperation_dir
. remove temporary dir
. generate a install_sw.sh and local_bootstrap.dat script in target_preperation_dir
#}

{% macro saltdeploy_prepare(salt_settings, gpg_id, gpg_key_location, make_targetdir, host_targetdir, hostname, domainname, custom_ssh_identity, netcfg) %}

{% set salt_config=salt_settings.master.config|load_yaml %}
{% set tempdir= salt['cmd.run_stdout']('mktemp -d -q') %}
{% set workdir= tempdir+ '/data' %}
{% set gpg_key= tempdir+ '/'+ salt['cmd.run_stdout']('basename '+ gpg_key_location) %}

{% for a in ("salt", "pillar") %}
smm-makedir-{{ a }}:
  file.directory:
    - name: {{ workdir }}/{{ a }}
    - makedirs: true
{% endfor %}

copy_bootstrap-salt.sh:
  file.managed:
    - name: {{ workdir }}/bootstrap-salt.sh
    - source: {{ salt_settings.install.bootstrap }}
    - source_hash: {{ salt_settings.install.bootstrap_hash }}
    - mode: 755

{% for a in salt_config.file_roots.base %}
copy_statedir_{{ a }}:
  cmd.run:
    - name: cp -ar -H -t {{ workdir }}/salt/ {{ a }}
{% endfor %}

{% for a in salt_config.pillar_roots.base %}
copy_pillardir_{{ a }}:
  cmd.run:
    - name: cp -ar -H -t {{ workdir }}/ {{ a }}
{% endfor %}

# this generates a new gpg key and pipes the secret portion of the key to gpg again to crypt it with the target recipient
# note: generated secret key never touches storage unencrypted
copy-publickey:
  file.managed:
    - name: {{ gpg_key }}
    - source: {{ gpg_key_location }}

import-target-publickey:
  cmd.run:
    - cwd: {{ tempdir }}
    - name: gpg --batch --yes --no-default-keyring --keyring ./tempring --secret-keyring ./tempring.sec --import {{ gpg_key }}
    - require:
      - file: copy-publickey

generate-saltmaster-gpgkey:
  cmd.run:
    - cwd: {{ tempdir }}
    - name: | 
       gpg --batch --yes --no-default-keyring --armor --enable-special-filenames --gen-key 3> >(\
         gpg --batch --yes --no-default-keyring --keyring ./tempring --always-trust --recipient {{ gpg_id }} \
         --output {{ tempdir }}/saltmaster@{{ hostname }}.secret.asc.crypted --encrypt) << EOF
       %echo Generating key
       Key-Type: 1
       Key-Length: 2560
       Name-Real: saltmaster@{{ hostname }}
       Expire-Date: 0
       %pubring {{ tempdir }}/saltmaster@{{ hostname }}.key.asc
       %secring -&3
       %commit
       %echo done
       EOF
    - require:
      - cmd: import-target-publickey

add_key_and_lock_repos:
  cmd.run:
    - name: |
        cd {{ tempdir }}
        mkdir -m 0700 .gnupg
        export GNUPGHOME={{ tempdir }}/.gnupg
        gpg --batch --yes --import {{ tempdir }}/saltmaster@{{ hostname }}.key.asc
        gpg --fingerprint --with-colons --list-keys |
          awk -F: -v keyname="saltmaster@{{ hostname }}" -v trustlevel="6" '
                $1=="pub" && $10 ~ keyname { fpr=1 }
                $1=="fpr" && fpr { fpr=$10; exit }
                END {
                    cmd="gpg --export-ownertrust"
                    while (cmd | getline) if ($1!=fpr) print
                    close(cmd)
                    print fpr ":" trustlevel ":"
                }
            ' | gpg --import-ownertrust
        for a in `find {{ workdir }} -name .git-crypt -type d`; do 
          cd $a/..
          git-crypt add-gpg-user saltmaster@{{ hostname }}
          git-crypt lock
        done

    - require:
      - cmd: generate-saltmaster-gpgkey

make_archive:
  cmd.run:
    - name: cd {{ workdir }}; tar caf {{ tempdir }}/saltmaster@{{ hostname }}_config.tar.xz .
    - unless: test -f {{ tempdir }}/saltmaster@{{ hostname }}_config.tar.xz

copy_archive:
  file.copy:
    - name: {{ make_targetdir }}/saltmaster@{{ hostname }}_config.tar.xz
    - source: {{ tempdir }}/saltmaster@{{ hostname }}_config.tar.xz
    - makedirs: true
    - force: true
    - require:
      - cmd: make_archive

copy_crypted_secret:
  file.copy:
    - name: {{ make_targetdir }}/saltmaster@{{ hostname }}.secret.asc.crypted
    - source: {{ tempdir }}/saltmaster@{{ hostname }}.secret.asc.crypted
    - force: true

{% for source,target in (('install_sw.sh', 'install_sw.sh'), ('local_bootstrap.sh', 'local_bootstrap.dat')) %}

generate_bootstrap_{{ source }}:
  file.managed:
    - name: {{ make_targetdir }}/{{ target }}
    - source: salt://old/roles/salt/files/{{ source }}
    - mode: 700
    - template: jinja
    - context:
        targetdir: {{ host_targetdir }}
        hostname: {{ hostname|d(" ") }}
        domainname: {{ domainname|d(" ") }}
        custom_ssh_identity: {{ custom_ssh_identity|d("") }}
        netcfg: {{ netcfg }}
        bootstrap_extra: {{ salt_settings.bootstrap_extra|d({}) }}
        install: {{ salt_settings.install|d(none) }}
        states:
{% for a in salt_config.file_roots.base %}
          - {{ salt['cmd.run_stdout']('basename '+ a) }}
{% endfor %}
        pillars:
{% for a in salt_config.pillar_roots.base %}
          - {{ salt['cmd.run_stdout']('basename '+ a) }}
{% endfor %}
    - require_in:
      - file: delete_temp_dir
{% endfor %}

delete_temp_dir:
  file.absent:
    - name: {{ tempdir }}
    - require:
      - file: copy_archive
      - file: copy_crypted_secret

{% endmacro %}

