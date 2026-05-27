#!/bin/bash

cd ${1:-.}
rm $(ls | grep -v '.c$') 2> /dev/null

files=($(ls))

for f in "${files[@]}"; do
	#echo $f
	mv -v $f $( \
		echo $f \
		| grep -oE '(_2[0-9]{5}_)|(re.*\.c)' \
		| tr -d _ \
		| paste -s -d '-' \
	) 2> /dev/null
done

