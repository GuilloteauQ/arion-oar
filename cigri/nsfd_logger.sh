
while true
do
    # R_AND_D=0
    # count=0
    # starting_time=$(date +%s)

    # while (( $(($(date +%s) - $starting_time)) < 5 ))
    # do
    #     TMP_R_AND_D=$(ps -eo s,command | grep "\[nfsd\]" | cut -f1 -d " " | grep -e "R" -e "D" -c)
    #     # TMP_R_AND_D=$(ps -eo s,command | grep "\[dd\]" | cut -f1 -d " " | grep -e "R" -e "D" -c)

    #     # TMP_R_AND_D=$(ps -eo s,command | grep "\[nfsd\]" -c)
    #     R_AND_D=$(($R_AND_D + $TMP_R_AND_D))
    #     count=$(($count + 1))
    # done

    # # NORMALIZED_R_AND_D=$(expr $R_AND_D / $count)
    # NORMALIZED_R_AND_D=$(python -c "print($R_AND_D / $count)")

    R_AND_D=$(ps -eo s,command | grep "\[nfsd\]" | cut -f1 -d " " | grep -e "R" -e "D" -c)
    # echo "$(date +%s), ${R_AND_D}, ${count}, ${NORMALIZED_R_AND_D}"
    # echo "$(date +%s.%N), ${R_AND_D}, ${NORMALIZED_R_AND_D}"
    echo "$(date +%s), ${R_AND_D}"
    sleep 5
done

