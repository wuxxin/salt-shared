if type apt-get >/dev/null 2>&1; then
    export DEBIAN_FRONTEND=noninteractive
    apt-get -y update
    apt-get -y upgrade
    apt-get -y install curl
    apt-get clean
fi
if type yum >/dev/null 2>&1; then
    yum -y update
    yum -y install wget curl openssh-server ca-certificates
fi

