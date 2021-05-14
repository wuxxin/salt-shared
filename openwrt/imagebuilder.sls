openwrtorg/imagebuilder

VERSION: snapshot
TARGET: x86-64
# DOCKER_USER, DOCKER_PASS and DOCKER_IMAGE

PROFILE - specifies the target image to build
PACKAGES - a list of packages to embed into the image
FILES - directory with custom files to include
BIN_DIR - alternative output directory for the images
EXTRA_IMAGE_NAME - Add this to the output image filename (sanitized)
DISABLED_SERVICE

git clone git://git.openwrt.org/openwrt.git
git clone git://git.openwrt.org/packages.git

apt-get install subversion build-essential libncurses5-dev zlib1g-dev gawk git ccache gettext libssl-dev xsltproc
apt-get install build-essential subversion git-core libncurses5-dev zlib1g-dev gawk flex quilt xsltproc
