#!/bin/bash
if [ ! -d ${TEST_DIR}/common/bats/report ] ; then
  mkdir -p ${TEST_DIR}/common/bats/report
fi
bats -t -r ${TEST_DIR}/common/bats/ | tee ${TEST_DIR}/common/bats/report/bats-tap.log
