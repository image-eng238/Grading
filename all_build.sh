#!/bin/bash
bin_dir='.'
source_dir='.'

while getopts s:b:h opt; do
	case $opt in
	s)
	source_dir=$OPTARG
	;;
	b)
	bin_dir=$OPTARG
	;;
	h)
	echo -b binary directory
	echo -s source file directory
	echo -h show this
	exit 0
	;;
	*)
	exit 1
	;;
	esac
done

c_source_files=($(ls $source_dir))

for sfile in "${c_source_files[@]}"; do
	echo "> building $sfile"
	gcc \
		-g $source_dir/$sfile \
		-o $bin_dir/$(echo $sfile | tr -d .c)

	if [ ${?} -eq 0 ]; then
		echo "> success"
	else
		echo "> fail"
	fi
done
