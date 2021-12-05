#!/bin/bash
#npm install -g markdown-link-check

# Check dead links
check_deadlinks=true

if [ "$check_deadlinks" == "true" ]; then
    succ=1
    function check_dead_link(){
        for file in `ls $1`
        do
            if [ -d $1"/"$file ]; then
                check_dead_link $1"/"$file $2
            elif [ "${file: 0-3 :3}" == ".md" ]; then
                markdown-link-check $1"/"$file -c ./.github/scripts/check_dead_link_conf.json || succ=0
            fi
        done
    }
    echo "Start to check dead links."
    check_dead_link kolo-lang
    check_dead_link byzer-notebook
    if [ $succ -eq 0 ]; then
        echo "Found dead links, please find logs above."
        exit 1
    fi || exit 0;
fi

