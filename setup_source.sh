#!/bin/bash

cd data
rm $(ls | grep -v '.c') 2> /dev/null
cd ..

files=($(ls ./data/))

for f in "${files[@]}"; do
	echo $f
	mv ./data/$f \
	./data/$( \
		echo $f \
		| grep -oE '(_258[0-9]*_)|(re.*\.c)' \
		| tr -d _ \
		| paste -s -d '-' \
	) 2> /dev/null
done
