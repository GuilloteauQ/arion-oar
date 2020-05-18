BASE_CGROUP_PATH=/sys/fs/cgroup/cpuset/docker
NUMBER_CPUS=$(grep -c ^processor /proc/cpuinfo)
CPU_index=0

# Returns the Id and the name of each container running
docker inspect --format='{{.Id}} {{.Name}}' $(docker ps -q) | while read line ; do
    # Some string processing to be able to link easily the name and id of container
    CONTAINER_ID=$(echo ${line} | cut -f1 -d ' ')
    CONTAINER_NAME=$(echo ${line} | cut -f2 -d ' ')
    echo "[*] Mapping ${CONTAINER_NAME} to CPU ${CPU_index}"
    # The mapping
    echo ${CPU_index} > ${BASE_CGROUP_PATH}/${CONTAINER_ID}/cpuset.cpus
    # Managing the index of the CPU for future mapping
    CPU_index=$(((${CPU_index}+1)% ${NUMBER_CPUS}))
done
