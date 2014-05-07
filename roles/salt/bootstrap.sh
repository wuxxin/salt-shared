echo "bootstrap a salt master including gitfs"
curl -L http://bootstrap.saltstack.org | sudo sh -s -- -M -N
apt-get install python-pip
pip install GitPython