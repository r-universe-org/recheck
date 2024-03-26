#!/bin/bash -l
set -e
echo "Reverse dependency check for: ${PACKAGE}"
Rscript -e "recheck::revdep_check('${PACKAGE}')"
echo "Action complete!"
