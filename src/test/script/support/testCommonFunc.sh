#/bin/bash

LoadTestEnv () {
  source $(find ${TEST_DIR} -name test.env -type f)
}

RegexAssertFile () {
  LoadTestEnv
  if [ $# -ne 2 ] ; then
    echo "args count error. usage:RegexAssertFile [EXPECTED_FILE] [ACTUAL_FILE]"
    return 1
  fi
  EXPECTED_FILE=$1
  ACTUAL_FILE=$2
  if [ ! -f ${EXPECTED_FILE} ] ; then
    echo "${EXPECTED_FILE} is not file. usage:RegexAssertFile [EXPECTED_FILE] [ACTUAL_FILE]"
    return 1
  fi
  if [ ! -f ${ACTUAL_FILE} ] ; then
    echo "${ACTUAL_FILE} is not file. usage:RegexAssertFile [EXPECTED_FILE] [ACTUAL_FILE]"
    return 1
  fi
  EXP_LINE_CNT=$(wc -l < ${EXPECTED_FILE})
  ACT_LINE_CNT=$(wc -l < ${ACTUAL_FILE})

  if [ ${EXP_LINE_CNT} -ne ${ACT_LINE_CNT} ] ; then
    echo "mismatch line count. expected=${EXP_LINE_CNT} actual=${ACT_LINE_CNT}" 1>&2
    return 1
  fi
  
  i=0
  while read line
  do
    let i+=1
    REGEX_EXPECTED_LINE=$(eval "echo \"$(sed -n ${i}p ${EXPECTED_FILE})\"")
    if [[ ! "${line}" =~ ^${REGEX_EXPECTED_LINE}$ ]] ; then
      echo "mismatch line. line_num=${i}" 1>&2
      echo "  actual  :${line}" 1>&2
      echo "  expected:^${REGEX_EXPECTED_LINE}$" 1>&2
      return 1
    fi
  done < ${ACTUAL_FILE}
  return 0
}

SqlForTest () {
  if [ $# -ne 2 ] ; then
    echo "args count error. usage:SqlForTest [SQL statement]"
    return 1
  fi
  psql -q -v ON_ERROR_ROLLBACK=1 -v ON_ERROR_STOP=1 -f "$1" > $2 \
    || echo "SqlForTest error."
  return 0
}

CopyTableFromTSV () {
  if [ $# -ne 2 ] ; then
    echo "args count error. usage:TestSql [SQL statement]"
    return 1
  fi
  TABLE_NAME=$1
  PREPARE_TSV_FILE=$2
  if [ ! -f ${PREPARE_TSV_FILE} ] ; then
    echo "${PREPARE_TSV_FILE} is not file. usage:CopyTableFromTSV [TABLE_NAME] [PREPARE_TSV_FILE]"
    return 1
  fi
  psql -q -v ON_ERROR_ROLLBACK=1 -v ON_ERROR_STOP=1 -c "copy ${TABLE_NAME} from stdin ( delimiter '	', format csv, header true ) " < ${PREPARE_TSV_FILE} \
    || echo "SqlForTest error."
}

CopyTableToTSV () {
  if [ $# -ne 2 ] ; then
    echo "args count error. usage:CopyTableToTSV [SELECT_SQL] [OUTPUT_TSV_FILE]"
    return 1
  fi
  SELECT_SQL=$1
  PREPARE_TSV_FILE=$2
  if [ ! -f ${PREPARE_TSV_FILE} ] ; then
    echo "${PREPARE_TSV_FILE} is not file. usage:CopyTableToTSV [SELECT_SQL] [OUTPUT_TSV_FILE]"
    return 1
  fi
  psql -q -v ON_ERROR_ROLLBACK=1 -v ON_ERROR_STOP=1 -c "copy (${SELECT_SQL}) to stdin ( delimiter '	', format csv, header true ) " > ${OUTPUT_TSV_FILE} \
    || echo "psql error." 1>&2
}

PrepareTableFromTSV () {
  if [ $# -ne 2 ] ; then
    echo "args count error. usage:PrepareTableFromTSV [TABLE_NAME] [PREPARE_TSV_FILE]"
    return 1
  fi
  TABLE_NAME=$1
  PREPARE_TSV_FILE=$2
  if [ ! -f ${PREPARE_TSV_FILE} ] ; then
    echo "${PREPARE_TSV_FILE} is not file. usage:PrepareTableFromTSV [TABLE_NAME] [PREPARE_TSV_FILE]"
    return 1
  fi
  SqlForTest "truncate table ${TABLE_NAME};"
  CopyTableFromTSV ${TABLE_NAME} ${PREPARE_TSV_FILE}  
  return 0
}

RegexAssertTable () {
  EXPECTED_FILE=$1
  SELECT_SQL=$2
  ACTUAL_FILE="${TEST_CASE_WORK_DIR}/$(echo ${SELECT_SQL} | sed s/ /_/g)"
  CopyTableToTSV "${SELECT_SQL}" "${ACTUAL_FILE}"
  RegexAssertFile "${EXPECTED_FILE}" "${ACTUAL_FILE}"
}

