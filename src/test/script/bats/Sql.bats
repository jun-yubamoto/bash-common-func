#!/usr/bin/env bats
load ${TEST_DIR}/support/batsCommonFunc.sh
load ${TEST_DIR}/support/testCommonFunc.sh
load /opt/bats-assert.bash

@test "normal" {
  export LOG_FILE=/srv/local/app/Sql.log
  run ${BATS_TEST_DIRNAME}/SqlFuncWrapper.sh ${TEST_FILE_DIR}/normal.sql ${TEST_CASE_WORK_DIR}/normal.result
  assert_success
  refute [ -e '/srv/local/app/Sql.log' ]
}

@test "sql error" {
  export LOG_FILE=/srv/local/app/Sql.log
  run ${BATS_TEST_DIRNAME}/SqlFuncWrapper.sh ${TEST_FILE_DIR}/error.sql ${TEST_CASE_WORK_DIR}/error.result
  assert_failure 1
#  assert_output --regexp '^.*\[ZZZZ-0000001\] \[ERROR\] System Error. DetailMsg\[detail\] \[Optional Message:testOptMsg\].*$'
  RegexAssertFile ${TEST_FILE_DIR}/sqlerror.log ${LOG_FILE}
}

@test "args count error" {
  unset LOG_FILE
  run ${BATS_TEST_DIRNAME}/SqlFuncWrapper.sh
  assert_failure 1
  assert_output --regexp '^.*\[ZZZZ-0000001\] \[ERROR\] System Error. DetailMsg\[args count error\.\].*$'
}

@test "arg1 is not file" {
  unset LOG_FILE
  run ${BATS_TEST_DIRNAME}/SqlFuncWrapper.sh "NOTFILE" "aaa"
  assert_failure 1
  assert_output --regexp '^.*\[ZZZZ-0000001\] \[ERROR\] System Error. DetailMsg\[args error\. NOTFILE is not file\.\].*$'
}



