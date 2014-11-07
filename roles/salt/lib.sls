include:
  - gpg

# salt - master - make
##########################

{% macro saltmaster_make(s, publicgpg_key, publicgpg_id, targetdir, targethost_targetdir) %}

{% set salt_config=s.master.config|load_yaml %}
{% set tempdir= salt['cmd.run_stdout']('mktemp -d -q') %}
{% set workdir= tempdir+ '/data' %}

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

make_archive:
  cmd.run:
    - name: cd {{ workdir }}; tar caf {{ tempdir }}/saltmaster_config.tar.xz .
    - unless: test -f {{ tempdir }}/saltmaster_config.tar.xz

copy_archive:
  file.copy:
    - name: {{ targetdir }}/saltmaster_config.tar.xz
    - source: {{ tempdir }}/saltmaster_config.tar.xz
    - makedirs: true

{% endmacro %}

{% from "roles/salt/defaults.jinja" import settings as s with context %}

{{ saltmaster_make(s, "salt://roles/imgbuilder/files/insecure_gpgkey.key.asc", "insecure_gpgkey", "/mnt/images/templates/imgbuilder/omoikane/", "/srv") }} 

{#

generate-saltmaster-gpgkey:
  cmd.run:
    - name: gpg --genkey whatever && gpg encrypt key.secret.asc key.secret.asc.encrypted
    - unless: test -f key.secret.asc.encrypted

cat >foo <<EOF
     %echo Generating a standard key
     Key-Type: 1
     Key-Length: 2560
     Name-Real: Joe Tester
     Expire-Date: 0
     %pubring foo.pub
     %secring foo.sec
     # Do a commit here, so that we can later print "done" :-)
     %commit
     %echo done
EOF
gpg --no-default-keyring --batch --gen-key foo
gpg --no-default-keyring --secret-keyring ./foo.sec --keyring ./foo.pub --list-secret-keys
gpg  --batch --yes --always-trust --recipient userid --encrypt sourcefile --output outputfile
# set trustlevel ($1 = userid $2=trustlevel)

gpg --fingerprint --with-colons --list-keys |
  awk -F: -v keyname="$1" -v trustlevel="$2" '
        $1=="pub" && $10 ~ keyname { fpr=1 }
        $1=="fpr" && fpr { fpr=$10; exit }
        END {
            cmd="gpg --export-ownertrust"
            while (cmd | getline) if ($1!=fpr) print
            close(cmd)
            print fpr ":" trustlevel ":"
        }
    ' | gpg --import-ownertrust

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