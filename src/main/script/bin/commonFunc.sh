#!/bin/bash

LoadCommonEnv(){
  ENV_FILE=$(find ${COMMON_BASH_DIR} -type f -name common.env)
  . ${ENV_FILE}
}

PrintLog () {
  LoadCommonEnv
  if [ $# -ne 2 -a $# -ne 3 ] ; then
    echo "args count error."
    return 1
  fi

  CALLER=""
  index=0
  while frame=($(caller "${index}")); do
    ((index++))
    CALLER="($(basename ${frame[2]}):${frame[0]})>${CALLER}"
  done
  MSG_ID=$1
  MSG_PARAM=$2
  OPT_MSG=$(echo "$3" | sed -e "s/\*/\\\*/g" -e "s/\&/\\&/g")
  MSG_RECORD=$(grep "^${MSG_ID}," -m 1 -h ${LOG_MESSAGE_FILES})
  if [ -z "${MSG_RECORD}" ] ; then
    echo "not found MSG_ID. ${MSG_ID}"
    return 1
  fi

  IFS_ORG=${IFS}
  IFS=',' read -r GET_MSG_ID MSG_LEVEL GET_MESSAGE <<< ${MSG_RECORD} 
  IFS=${LOG_DELIM_CHAR}
  set -- ${MSG_PARAM}
  MESSAGE=$(eval echo "${GET_MESSAGE}")
  if [[ -n "${OPT_MSG}" ]] ; then
    MESSAGE="${MESSAGE} [Optional Message:${OPT_MSG}]"
  fi

  IFS=${IFS_ORG}
  DATE=$(date "+${LOG_DATE_FORMAT}")
  if [ -z "${LOG_FILE}" ] ; then
    eval "echo ${LOG_FORMAT}"
  else
    eval "echo ${LOG_FORMAT}" 2>&1 | tee -a ${LOG_FILE}
  fi
  return 0
}

Sql () {
  LoadCommonEnv
  if [ $# -ne 2 ] ; then
    PrintLog "${CMN_SYSERR_MSG_ID}" "args count error."
    return 1
  fi

  if [ ! -f $1 ] ; then
    PrintLog "${CMN_SYSERR_MSG_ID}" "args error. $1 is not file."
    return 1
  fi

  _SQL_RETRY_INTERVAL_SEC=${SQL_RETRY_INTERVAL_SEC:-1}
  _SQL_RETRY_LIMIT=${SQL_RETRY_LIMIT:-1}
  TMP_SQL_FILE=$1.$$
  RESULT_FILE=$2
  printf "\pset pager off\n\\\a\n\pset fieldsep ','\n\pset footer off\n\set VERBOSITY verbose\n" > ${TMP_SQL_FILE}
  cat $1 >> ${TMP_SQL_FILE}
  counter=0
  while true
  do
    psql -q -v ON_ERROR_ROLLBACK=1 -v ON_ERROR_STOP=1 -f ${TMP_SQL_FILE} > ${RESULT_FILE} 2>&1
    RTN_CD=$?
    if [ ${RTN_CD} -eq 0 ] ; then
      rm -f ${TMP_SQL_FILE}
      break
    else
      #let counter++
      ((counter++))
      if [ ${_SQL_RETRY_LIMIT} -lt ${counter} ] ; then
         PrintLog "${CMN_SQL_RETRYOVER_MSG_ID}" "${_SQL_RETRY_LIMIT}${LOG_DELIM_CHAR}${counter}" "$(cat ${RESULT_FILE})"
         rm -f ${TMP_SQL_FILE}
         return 1
      fi
      sleep ${_SQL_RETRY_INTERVAL_SEC}
      PrintLog "${CMN_SQL_RETRY_MSG_ID}" "${_SQL_RETRY_LIMIT}${LOG_DELIM_CHAR}${counter}${LOG_DELIM_CHAR}${_SQL_RETRY_INTERVAL_SEC}"
    fi 
  done
  return 0
}


