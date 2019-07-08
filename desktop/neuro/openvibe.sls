
lxc launch ubuntu-daily:xenial -p default -p gui openvibe
devices:
  ttyUSB0:
    mode: "666"
    path: /dev/ttyUSB0
    type: unix-char
    
lxc exec openvibe -- sudo --user ubuntu --login

git clone https://gitlab.inria.fr/openvibe/meta.git openvibe
cd openvibe/
git submodule update --init --recursive
export DEBIAN_FRONTEND=noninteractive
apt install ninja-build
./install_dependencies.sh
./build.sh
