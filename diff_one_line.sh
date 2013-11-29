#!/bin/sh 

tmp_dir="__temp"
self_log_file="$tmp_dir/lllogcover.log"
file_cover_dir="$tmp_dir/_logcover_dir/"

function log()
{
	echo $1 >> $self_log_file
}

function not_match()
{
	log "call not match"
	echo "$2%%%$3%%%$4" >> $file_cover_dir/$1_notcover
}

function match()
{
	log "call match"
	echo "$2%%%$3%%%$4" >> $file_cover_dir/$1_cover
}


function parse_log()
{
#    log=${log//[/\\[}
#    log=${log//]/\\]}
    log=${log//\%d/[0-9]\\+}
    log=${log//\%s/.*?}
    log=${log//\%lu/[0-9]\\+}
    log=${log//\%llu/[0-9]\\+}
    #echo $log
}

function find_line()
{
	log "call find_line $file%%$line_num%%"
	grep "$file\%\%$line_num\%\%" $log_result >/dev/null 2>&1
	return $?
}

function diff_one_line()
{
    line=$1
    
    echo $line | awk -F'%%' '{print $1,$2,$3,$4}' | while read file line_num type log 
    do
    
    find_line
    
    if [ $? -eq 0 ];then
    	#match "$file" "$line_num" "$log"
    	exit 0
    else
    	not_match "$file" "$line_num" "$type" "$log"
    fi
    done
}

#main "$@"
