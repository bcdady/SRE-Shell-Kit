#!/usr/bin/env bash
# requires - brew install cloc

for TOOL in cloc jq; do
  which $TOOL >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    printf "ERROR: couldn't find $TOOL tool. Exiting...\n"
    exit 127
  fi
done

cd ~/repo/GitStats
input="GitStats.txt"

while IFS= read -r line; do
  printf "INFO: Processing $line...\n"
  # $REPO is a URI like git@subsplash.io:release/google-play.git // extract git@subsplash.io\:(.+)\.git
  #REPO="git@subsplash.io:release/google-play.git"
  #re="\w+$"
  #if [[ $line =~ $re ]]; then LOCAL=${BASH_REMATCH[1]}; fi
  LOCAL=`basename $line`

  printf "INFO: Running cloc on repo $LOCAL ...\n"
  # create an output filename to be written by the following invocation of cloc
  # Details to collect: App Name, Description, Language(s) used, Target Platform, and Estimated lines of code (exclude 3rd party libraries/modules)
  OUTFILE="$LOCAL-stats.csv" # example: kubernetes-app-helm-chart_stats.csv
  # printf "cloc --exclude-dir=vendor --yaml --file-encoding='UTF-8' --out=$OUTFILE $line\n"
  cloc --exclude-dir=vendor --csv --file-encoding="UTF-8" --out=$OUTFILE $line # $LOCAL  # Output options include --csv --md --file-encoding="UTF-8" --yaml --out=FILE
  # insert source path into the resulting yaml file :: awk '{print} sub(/elapsed_seconds/,"source_path        : {PATH}\n  elapsed_seconds")' ./test.yaml
  # insert source path into the resulting csv file 
  # printf "Updating output file to include source directory \n"
  awk '{print} sub(/code\,\"github.com\/AlDanial\/cloc/,"code, source = '$LOCAL', cloc")' $OUTFILE > stats.tmp
  # replace the original header line
  sed '1d' stats.tmp > $OUTFILE
  cat $OUTFILE >> summary_stats.csv
 
  # then clenanup /delete the earlier tmp file
  rm -f stats.tmp

done < "$input"

echo "Done!"

exit 0