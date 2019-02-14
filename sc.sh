#!/bin/bash
scriptpath=$(dirname "$(readlink -e "$0")")
basepath=$(readlink -e "$scriptpath/../..")
runpath=$basepath/_run

install_salt() {
    defpara="-X"
    if test ! "$@" = ""; then
      echo "not using default parameter ($defpara), using parameter $@"
      defpara=$@
    fi

    if test ! -f /tmp/bootstrap-salt.sh; then
        echo "download bootstrap salt"
        curl -L -o /tmp/bootstrap-salt.sh https://bootstrap.saltstack.com
        chmod +x /srv/bootstrap-salt.sh
    fi

    echo "calling /tmp/bootstrap-salt.sh with $defpara"
    sudo /srv/bootstrap-salt.sh $defpara
    echo "disabling salt-minion from running"
    sudo sh -c "for i in stop disable mask; do systemctl $i salt-minion; done"
    
    echo "generating config files"
    mkdir $runpath
    cat | sed -re "s:##BASE##:$basepath:g" > $runpath/minion <<EOF
root_dir: ##BASE##/_run
pidfile: salt-minion.pid
pki_dir: pki
cachedir: cache
sock_dir: run
file_client: local

fileserver_backend:
- roots
pillar_roots:
  base:
  - ##BASE##/pillar

file_roots:
  base:
  - ##BASE##/salt/salt-shared
  - ##BASE##/salt/custom

EOF

    echo -e "id: $(hostname)" >> $runpath/minion

}


if ! which salt-call; then 
    install_salt
fi
sudo salt-call --local --config-dir=$runpath $@
