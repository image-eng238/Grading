#!/bin/bash

if [ -d data ]; then
	cd data
	rm -rf *
	cd ..
else
	mkdir data
fi

if [ -d bin ]; then
	cd bin
	rm -rf *
	cd ..
else
	mkdir bin
fi

if [ -d log ]; then
	cd log
	rm -rf *
	cd ..
else
	mkdir log
fi
