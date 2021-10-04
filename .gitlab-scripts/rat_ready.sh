while true # infinite loop
do
    # try the command, and catch its output:
    output=$(docker logs $(docker ps | grep rat | awk '{print $1}')  | grep -o READY_FOR_TESTING)

    if [ -z "$output" ]
    then
        # output is non-empty - continue:
        echo "waiting"
        sleep 1
    else
        break
    fi

done