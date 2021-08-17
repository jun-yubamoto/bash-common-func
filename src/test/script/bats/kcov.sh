#!/bin/bash
if [ ! -d ${TEST_DIR}/common/bats/report ] ; then
  mkdir -p ${TEST_DIR}/common/bats/report
fi
kcov --bash-dont-parse-binary-dir --include-path=${COMMON_BASH_DIR}/bin ${TEST_DIR}/common/bats/report/kcov-report ${TEST_DIR}/common/bats/bats-suite.sh
