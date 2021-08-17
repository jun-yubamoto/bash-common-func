#!/bin/bash -x
set -euo pipefail
source ./testCommonFunc.sh
RegexAssertFile $1 $2

#  if [ $# -ne 2 ] ; then
#    echo "args count error. usage:RegexAssertFile [EXPECTED_FILE] [ACTUAL_FILE]"
#    exit 1
#  fi
#  EXPECTED_FILE=$1
#  ACTUAL_FILE=$2
#  if [ ! -f ${EXPECTED_FILE} ] ; then
#    echo "${EXPECTED_FILE} is not file. usage:RegexAssertFile [EXPECTED_FILE] [ACTUAL_FILE]"
#    exit 1
#  fi
#  if [ ! -f ${ACTUAL_FILE} ] ; then
#    echo "${ACTUAL_FILE} is not file. usage:RegexAssertFile [EXPECTED_FILE] [ACTUAL_FILE]"
#    exit 1
#  fi
#
#  i=0
#  while read line
#  do
#    let i++
##    REGEX_EXPECTED_LINE=$(sed -n ${i}p ${EXPECTED_FILE} | envsubst)
#    REGEX_EXPECTED_LINE=$(eval "echo \"$(sed -n ${i}p ${EXPECTED_FILE})\"")
#    if [[ ! "${line}" =~ ^${REGEX_EXPECTED_LINE}$ ]] ; then
#      echo "mismatch line. line_num=${i}"
#      echo "  actual  :${line}"
#      echo "  expected:^${REGEX_EXPECTED_LINE}$"
#      exit 1
#    fi
#  done < ${ACTUAL_FILE}
#  exit 0

