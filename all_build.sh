#!/bin/bash

c_source_files=($(ls ./data/))

for sfile in "${c_source_files[@]}"; do
	echo "> building $sfile"
	gcc \
		-g ./data/$sfile \
		-o ./bin/$(echo $sfile | tr -d .c)

	if [ ${?} -eq 0 ]; then
		echo "> success"
	else
		echo "> fail"
	fi
done
