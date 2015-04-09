{% set STDEB_VERSION="0.8.5" %}


# Download stdeb
wget http://pypi.python.org/packages/source/s/stdeb/stdeb-$STDEB_VERSION.tar.gz

# Extract it
tar xzf stdeb-$STDEB_VERSION.tar.gz

# Enter extracted source package
cd stdeb-$STDEB_VERSION

# Build .deb (making use of stdeb package directory in sys.path).
python setup.py --command-packages=stdeb.command bdist_deb

# Install it
sudo dpkg -i deb_dist/python-stdeb_$STDEB_VERSION-1_all.deb
