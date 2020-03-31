#!/bin/bash

NAME_OF_TEST_JOB=$1
NUMBER_OF_JOBS=$2
SLEEP_TIME=$3

# Creation of the exec file
EXEC_FILE="exec_file_sleep_${SLEEP_TIME}.sh"

exec_file_content="$(cat <<EOF
#!/bin/bash
echo \$2 > \$1
sleep ${SLEEP_TIME}
EOF
)"

echo "$exec_file_content" > $EXEC_FILE
chmod 777 $EXEC_FILE

file_content="$(cat <<EOF
{
  "name": "${NAME_OF_TEST_JOB}",
  "resources": "resource_id=1",
  "exec_file": "sh $(pwd)/${EXEC_FILE}",
  "test_mode": "false",
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
    $(for i in $(seq "$(($NUMBER_OF_JOBS - 1))"); do echo -e "\t\"param$i $i\",";done)
    $(echo -e "\t\"param$NUMBER_OF_JOBS $NUMBER_OF_JOBS\"")
  ]
}
EOF
)"

echo "${file_content}" > ${NAME_OF_TEST_JOB}.json

