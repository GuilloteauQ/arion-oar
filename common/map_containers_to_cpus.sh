BASE_CGROUP_PATH=/sys/fs/cgroup/cpuset/docker
NUMBER_CPUS=$(grep -c ^processor /proc/cpuinfo)
CPU_index=0

if [ "$1" = "manual" ]; then
    # Returns the Id and the name of each container running
    CONTAINER_NAMES=$(docker inspect --format='{{.Name}}' $(docker ps -q))
    for container_name in ${CONTAINER_NAMES}; do
        # Some string processing to be able to link easily the name and id of container
        CONTAINER_ID=$(docker inspect ${container_name} --format='{{.Id}}')
        # Asking the user for the CPU (s)he wants the container to be mapped to
        read -p "Where do you want to map ${container_name} ?: " chosen_CPU_index
        echo -e "\033[32m[*] Mapping ${container_name} to CPU ${chosen_CPU_index}\033[39m"
        # The mapping
        echo ${chosen_CPU_index} > ${BASE_CGROUP_PATH}/${CONTAINER_ID}/cpuset.cpus
    done
else
    # Returns the Id and the name of each container running
    docker inspect --format='{{.Id}} {{.Name}}' $(docker ps -q) | while read line ; do
        # Some string processing to be able to link easily the name and id of container
        CONTAINER_ID=$(echo ${line} | cut -f1 -d ' ')
        CONTAINER_NAME=$(echo ${line} | cut -f2 -d ' ')
        echo -e "\033[32m[*] Mapping ${CONTAINER_NAME} to CPU ${CPU_index}\033[39m"
        # The mapping
        echo ${CPU_index} > ${BASE_CGROUP_PATH}/${CONTAINER_ID}/cpuset.cpus
        # Managing the index of the CPU for future mapping
        CPU_index=$(((${CPU_index}+1)% ${NUMBER_CPUS}))
    done
fi
