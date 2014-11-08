include:
  - gpg

# salt - master - make
##########################

{% macro saltmaster_make(s, gpg_key_location, gpg_id, make_targetdir, hostname, host_targetdir) %}

{% set salt_config=s.master.config|load_yaml %}
{% set tempdir= salt['cmd.run_stdout']('mktemp -d -q') %}
{% set workdir= tempdir+ '/data' %}
{% set gpg_key= tempdir+ '/'+ salt['cmd.run_stdout']('basename '+ gpg_key_location) %}

{% for a in ("salt", "reactor", "pillar") %}
smm-makedir-{{ a }}:
  file.directory:
    - name: {{ workdir }}/{{ a }}
    - makedirs: true
{% endfor %}

{% for a in salt_config.file_roots.base %}
copy_statedir_{{ a }}:
  cmd.run:
    - name: cp -ar -t {{ workdir }}/salt/ {{ a }}
{% endfor %}

{% for a in salt_config.pillar_roots.base %}
copy_pillardir_{{ a }}:
  cmd.run:
    - name: cp -ar -t {{ workdir }}/ {{ a }}
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
    - name: cd {{ workdir }}; tar caf {{ tempdir }}/saltmaster_config.tar.xz .
    - unless: test -f {{ tempdir }}/saltmaster_config.tar.xz

copy_archive:
  file.copy:
    - name: {{ make_targetdir }}/saltmaster_config.tar.xz
    - source: {{ tempdir }}/saltmaster_config.tar.xz
    - makedirs: true
    - force: true

generate_install_sw:
  file.managed:
    - name: {{ make_targetdir }}/install_sw.sh

copy_crypted_secret:
  file.copy:
    - name: {{ make_targetdir }}/saltmaster@{{ hostname }}.secret.asc.crypted
    - source: {{ tempdir }}/saltmaster@{{ hostname }}.secret.asc.crypted
    - force: true

{% endmacro %}

{% from "roles/salt/defaults.jinja" import settings as s with context %}

{{ saltmaster_make(s, "salt://roles/imgbuilder/preseed/files/insecure_gpgkey.key.asc", "insecure_gpgkey", "/mnt/images/templates/imgbuilder/omoikane", "omoikane","/srv") }} 

{#
# set trustlevel ($1 = userid $2=trustlevel)


steps:
. copy all state and pillar paths together 
. generate saltmaster gpg key
. crypt saltmaster private gpg key with gpg_key of user
. add public key of this to every path where git-crypt says its working
  . git-crypt add-gpg-key ; git commit -c "added public gpg key y"
. git-crypt lock on every path
  . git-crypt lock

. make tar.gz out of temporary dir (without parents) and save it under target_preperation_dir
. remove temporary dir

. generate a install_sw.sh script in target_preperation_dir that:
  . connects to target host
  . transfers tar.gz to target
  . installs gpg and inserts keys into keychain of root

  . generate a local_bootstrap.sh to /targetdir for target machine that:
    . make /targetdir/bootstrap.run and refuse to continue if already exists
    . tar xaf tar.gz /targetdir
    . generates sc.sh minion and grains in /targetdir for a masterless setup
    . sc.sh state.sls repo 
    . sc.sh state.sls salt.git-crypt
    . checkout and unlocks git paths with git-unlock 
    . sc.sh state.sls salt.master
    . accept minion key
    . copy grains from /targetdir to /etc/salt/
    . /etc/init.d/salt-minion restart
    . rm /targetdir/_run /targetdir/minion /targetdir/grains
    . salt-call state.sls network.sls
    . salt-call state.sls storage.sls
    . salt-call state.highstate

#}