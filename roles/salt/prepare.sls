include:
  - git-crypt

{#

macro prepare_saltmaster

paths_to_pillar
paths_to_salt
salt_master_config
gpg_key of the user which the saltmaster gpg key is encrypted
target_dir on preperation machine
target_dir on target

steps:
. copy all paths to temporary dir
. generate saltmaster gpg key
. crypt saltmaster private gpg key with gpg_key of user
. add public key of this to every path where git-crypt says its working
. git-crypt lock on every path
. make tar.gz out of temporary dir (without parents)
. remove temporary dir
. generate a bootstrap.sh that:
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