#!/usr/bin/env bash

cd ~/repo/GitStats

#for file in $(find ./3p -name "*.csv"); do echo $file; done

for DIR in $(ls -d *); do
  printf "INFO: Working in $DIR ...\n"

  find $DIR -name "*.csv"
  for file in $(find $DIR -name "*.csv"); do
    echo "cat file: $file"
    cat $file >>GitLab_stats.txt
  done
  # echo "break"
  # break
done

exit 0
