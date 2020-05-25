
BASE_PATH=/sys/fs/cgroup/cpu
HZ=$(getconf CLK_TCK)

# echo "time,loadavg,user,system,nb_tasks,usage"
echo "time,loadavg,nb_tasks,nb_r_d"

# $1: process pid
get_process_state() {
    cat /proc/$1/status | sed -n 's/State:\t\([A-Z]\)/\1/p' | cut -f1 -d ' '
}

# $1: path
get_number_r_and_d_processes() {
    count=0
    PIDS=$(cat ${BASE_PATH}/tasks)
    for task_pid in ${PIDS}; do
        if [ -f /proc/${task_pid}/status ]; then
          STATE=$(get_process_state ${task_pid})
          if [ ${STATE} == "R" ] || [ ${STATE} == "D" ]; then
              count=$(($count + 1))
          fi
        fi
    done
    return ${count}
}

while true
do
    LOADAVG=$(cat /proc/loadavg | cut -f1 -d ' ')
    # MEASURE=$(cat ${BASE_PATH}/cpuacct.stat | cut -f2 -d ' ' | awk -v hz="${HZ}" '{print $1 / hz}' | paste -sd ",")
    # NB_TASKS=$(cat ${BASE_PATH}/tasks | wc -l)
    NB_TASKS=$(ps -e | wc -l)
    # get_number_r_and_d_processes
    # R_D_TASKS=$?
    R_D_TASKS=$(ps -eo s | grep -e "D" -e "R" -c)
    # USAGE=$(cat ${BASE_PATH}/cpuacct.usage)
    # echo "$(date +%s), ${LOADAVG},${MEASURE},${NB_TASKS},${USAGE}"
    echo "$(date +%s), ${LOADAVG},${NB_TASKS},${R_D_TASKS}"
done
