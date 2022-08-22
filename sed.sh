sed '6i\\
$'\\s' $'\\s' source_path'$'\\s''{8}: _path_'$'\n' ./test.yaml

awk '{print} sub(/elapsed_seconds/,"source_path        : {PATH}\n  elapsed_seconds")' ./test.yaml
