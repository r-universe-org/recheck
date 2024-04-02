#!/bin/bash -l
set -e
nohup Xvfb :6 -screen 0 1280x1024x24 > ~/X.log 2>&1 &
export DISPLAY=:6
echo "Reverse dependency check for: ${PACKAGE}"
Rscript -e "recheck::recheck('${PACKAGE}')"
echo "Action complete!"
