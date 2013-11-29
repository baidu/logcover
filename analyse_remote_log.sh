#!/bin/sh 

tmp_dir="__temp"
log_temp_base_dir="$tmp_dir/_log_base"
file_list="_file_list"
log_result_dir="log_result"

rm -rf $tmp_dir
rm -rf $log_result_dir

i=0

host=`hostname`
mkdir $log_temp_base_dir -p
mkdir $log_result_dir -p

while [ $# -ne 0 ];do
	log_temp_dir="${log_temp_base_dir}_${i}"
	log_temp_result="${log_temp_base_dir}/${i}.log"
    mkdir -p $log_temp_dir
	sh filter_log.sh $1 $log_temp_dir $file_list
	sh merge_log.sh $log_temp_dir $log_temp_result
	i=$[i+1]
	shift
done

sh merge_log.sh $log_temp_base_dir $log_result_dir/${host}.log


touch ${log_result_dir}/${host}_analyze.ok
