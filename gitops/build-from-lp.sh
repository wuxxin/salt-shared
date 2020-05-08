#!/bin/bash
set -eo pipefail
set -x


self_path=$(dirname "$(readlink -e "$0")")

. ${self_path}/gitops-library.sh

build_from_lp "$@"
