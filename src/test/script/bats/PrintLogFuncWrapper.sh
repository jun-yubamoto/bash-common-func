#!/bin/bash
. ${COMMON_BASH_DIR}/bin/commonFunc.sh

PrintLog $@
RTN_CODE=$?
exit ${RTN_CODE}

