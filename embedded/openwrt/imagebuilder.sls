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

apt-get install -y \
  build-essential libncurses5-dev libncursesw5-dev zlib1g-dev gawk git gettext libssl-dev xsltproc rsync wget unzip python
