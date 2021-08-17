#!/usr/bin/env bats
load ${TEST_DIR}/support/batsCommonFunc.sh
load ${TEST_DIR}/support/testCommonFunc.sh
load /opt/bats-assert.bash

@test "normal(LOG_FILE environ set)" {
  export LOG_FILE=/srv/local/app/PrintLog.log
  run ${BATS_TEST_DIRNAME}/PrintLogFuncWrapper.sh "ZZZZ-0000001" "detail"
  [ "${status}" -eq 0 ]
  assert_output --regexp '^.*\[ZZZZ-0000001\] \[ERROR\] System Error. DetailMsg\[detail\].*$'
  RegexAssertFile ${TEST_FILE_DIR}/1-PrintLog.log ${LOG_FILE}
}

@test "normal(optional message)" {
  export LOG_FILE=/srv/local/app/PrintLog.log
  run ${BATS_TEST_DIRNAME}/PrintLogFuncWrapper.sh "ZZZZ-0000001" "detail" "testOptMsg"
  [ "${status}" -eq 0 ]
  assert_output --regexp '^.*\[ZZZZ-0000001\] \[ERROR\] System Error. DetailMsg\[detail\] \[Optional Message:testOptMsg\].*$'
  RegexAssertFile ${TEST_FILE_DIR}/2-PrintLog.log ${LOG_FILE}
}

@test "normal(LOG_FILE environ unset)" {
  unset LOG_FILE
  run ${BATS_TEST_DIRNAME}/PrintLogFuncWrapper.sh "ZZZZ-0000001" "detail"
  [ "${status}" -eq 0 ]
  assert_output --regexp '^.*\[ZZZZ-0000001\] \[ERROR\] System Error. DetailMsg\[detail\].*$'
}

@test "args count error" {
  run ${BATS_TEST_DIRNAME}/PrintLogFuncWrapper.sh
  [ "${status}" -eq 1 ]
  [ "${output}" == "args count error." ]
}

@test "not found message id from message.csv" {
  run ${BATS_TEST_DIRNAME}/PrintLogFuncWrapper.sh "NOTFOUND_MSG_ID" "aaa"
  [ "${status}" -eq 1 ]
  [ "${output}" == "not found MSG_ID. NOTFOUND_MSG_ID" ]
}



