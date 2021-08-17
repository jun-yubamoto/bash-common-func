#/bin/bash

setup_file() {
  BATS_TEST_SIMPLE_FILENAME=$(basename ${BATS_TEST_FILENAME}) 
  export TEST_SIMPLE_FILENAME=${BATS_TEST_SIMPLE_FILENAME%.*}
  export TEST_FILE_DIR=${BATS_TEST_DIRNAME}/${TEST_SIMPLE_FILENAME}
  export TEST_FILE_WORK_DIR=${TEST_WORK_DIR}/${TEST_SIMPLE_FILENAME}
  rm -rf ${TEST_FILE_WORK_DIR}
  mkdir -p ${TEST_FILE_WORK_DIR}
  individual_setup_file
}

individual_setup_file() {
  return 0
}

setup() {
  TEST_CASE_WORK_DIR=${TEST_FILE_WORK_DIR}/${BATS_TEST_NUMBER}-${BATS_TEST_NAME}
  mkdir ${TEST_CASE_WORK_DIR}
  individual_setup
}

individual_setup() {
  return 0
}

teardown() {
  if [ -f ${LOG_FILE} ] ; then
    mv ${LOG_FILE} ${TEST_CASE_WORK_DIR}
  fi
  individual_teardown
}

individual_teardown() {
  return 0
}

teardown_file() {
  individual_teardown_file
}

individual_teardown_file() {
  return 0
}

