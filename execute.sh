#!/bin/bash

which tmux > /dev/null
if [ $? -ne 0 ]; then
	echo This script requires tmux to run
	exit 1
fi

bin_dir='.'
out_dir='.'
work_pane='1'
work_pipe=''
work_args=''

while getopts a:b:o:t:p:h opt; do
	case $opt in
	a)
	work_args=$OPTARG
	;;
	b)
	bin_dir=$OPTARG
	;;
	o)
	out_dir=$OPTARG
	;;
	t)
	work_pane=$OPTARG
	;;
	p)
	work_pipe=$OPTARG
	;;
	h)
	echo -a argument
	echo -b binary directory
	echo -o output directory
	echo -p send pipeline
	echo -t number of workspace pine
	echo -h show this
	exit 0
	;;
	*)
	exit 1
	;;
	esac
done

bin_dir=$(realpath $bin_dir)
out_dir=$(realpath $out_dir)

bin_files=($(ls $bin_dir))

for bin in "${bin_files[@]}"; do
	echo $bin is runnig...
	echo $bin > $out_dir/$bin.log
	tmux send-key -t $work_pane \
	-- "$bin_dir/$bin $work_args >> $out_dir/$bin.log" \
	Enter
	sleep 0.1

	tmux list-pane -sF "#{pane_id} #{pane_current_command}" \
		| grep -qE "%$work_pane .*$bin\$"
	if [ $? -eq 0 ]; then
		tmux send-key -t $work_pane \
		-- "$work_pipe" \
		Enter
	fi
	sleep 0.1

	tmux list-pane -sF "#{pane_id} #{pane_current_command}" \
		| grep -qE "%$work_pane .*$bin\$"
	if [ $? -eq 0 ]; then
        	tmux send-key -t $work_pane -- ^C
		echo "> failure" | tee -a $out_dir/$bin.log
		sleep 0.1
	else
		echo "> success" | tee -a $out_dir/$bin.log
	fi
done

