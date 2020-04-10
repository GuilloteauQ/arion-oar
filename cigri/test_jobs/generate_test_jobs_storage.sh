#!/bin/bash

NAME_OF_TEST_JOB=$1
NUMBER_OF_JOBS=$2
SIZE_OF_FILE=$3
STORAGE_TYPE=$4

# Creation of the exec file
EXEC_FILE="test_storage_${STORAGE_TYPE}.sh"

file_content="$(cat <<EOF
{
  "name": "${NAME_OF_TEST_JOB}",
  "resources": "resource_id=1",
  "exec_file": "sh $(pwd)/${EXEC_FILE}",
  "test_mode": "false",
  "heviness": true,
  "clusters": {
    "cluster_0": {
      "type": "best-effort",
      "walltime": "300"
    }
  },
  "prologue": [
    "mkdir $HOME/workdir",
    "cd $HOME/workdir",
    "touch prologue_works"
  ],
  "epilogue": [
    "cd $HOME/workdir",
    "touch epilogue_works"
  ],
  "params": [
    $(for i in $(seq "$(($NUMBER_OF_JOBS - 1))"); do echo -e "\t\"param$i $i $SIZE_OF_FILE\",";done)
    $(echo -e "\t\"param$NUMBER_OF_JOBS $NUMBER_OF_JOBS $SIZE_OF_FILE\"")
  ]
}
EOF
)"

echo "${file_content}" > ${NAME_OF_TEST_JOB}.json

