#!/bin/bash
file=$1
line=`fgrep __DATA__ -n $file | cut -d: -f1`
line=`expr $line + 1`
tail -n +$line $file