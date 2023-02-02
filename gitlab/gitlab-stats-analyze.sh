#!/usr/bin/env bash

cd ~/repo/GitStats || exit

#for file in $(find ./3p -name "*.csv"); do echo $file; done

for DIR in $(ls -d *); do
    printf "INFO: Working in %S ...\n" "${DIR}"

    find $DIR -mtime -7 -name '*.csv' -print0 | while IFS= read -r -d '' file
    for file in $(find $DIR -name "*.csv"); do
        echo "cat file: $file"
        cat $file >> GitLab_stats.txt
    done
    # echo "break"
    # break
done

exit 0
