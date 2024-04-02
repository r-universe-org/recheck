#!/bin/bash -l
set -e
nohup Xvfb :6 -screen 0 1280x1024x24 > ~/X.log 2>&1 &
export DISPLAY=:6
if [ -z "$1" ]; then
  echo "You need to pass a package tarball path or URL"
  exit 1
fi
echo "Reverse dependency check for: ${1}"
Rscript -e "recheck::recheck('${1}')"
echo "Action complete!"
