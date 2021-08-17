#!/bin/bash
. ${COMMON_BASH_DIR}/bin/commonFunc.sh

Sql $@
RTN_CODE=$?
exit ${RTN_CODE}

