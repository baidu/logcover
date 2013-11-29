#!/bin/sh 

source renderHtml.sh
source diff_one_line.sh
source logcover.cfg

src_result="$tmp_dir/src_result.txt"
log_result="$tmp_dir/filter.log"
wf_log_result="$tmp_dir/wf_filter.log"
file_list="$tmp_dir/_file_list"
log_temp_dir="$tmp_dir/_log/"
remote_tmp_result_log="$tmp_dir/_remote_tmp_log"
log_type="WARNING|FATAL|warning|fatal|log.error|log.critical|CRITICAL|ERROR|WARN|LOG.warn"
file_type=".*\\.\\(c\\|h\\|pl\\|cpp\\|php\\|py\\|java\\|cc\\)"
log_file_type="wf|"
log_process_ret="$tmp_dir/_log_process.ok"
code_process_ret="$tmp_dir/_code_process.ok"
log_process_fail="$tmp_dir/_log_process.fail"
file_cover_result_file="$tmp_dir/_cover_result_file"

function usage()
{
	echo "Usage:"
	echo "      ./logcover.sh svn_url log_dir email_addresses [-s email_subject]"
	echo "for example:"
	echo "      ./logcover.sh https://svn.baidu.com/inf/ds/branches/transkeeper/master/dev_2-0-0_BRANCH testlogs/ ls@baidu.com [ls2@baidu.com] [-s logcovertest]"
	exit 0
}

function clear_env()
{
	mkdir -p $tmp_dir
	rm -rf $tmp_dir/*
	mkdir -p $file_cover_dir
	rm -rf $file_cover_dir/*
}

function cal_diff_previous()
{
	local file=$1
	local percent=$2
	local base_file=$3
	if [ -f $base_file ];then
		previous_percent=`grep "^${file} " $base_file | awk '{print $2}'`
		if [ -z "$previous_percent" ];then
			diff_percent=0
			return
		fi
		not_zero=`echo "$previous_percent != 0"|bc`
		if [ $not_zero -eq 1 ];then
		    diff_percent=`echo "scale=2;($percent-$previous_percent)" | bc`
		else
			#diff_percent=$percent
			diff_percent=0
		fi
	else
		diff_percent=0
	fi
}

function generate_total_html()
{
    #generate html head

    #20130507 add diff with previous version by songjian02
    previous_base_file="_${fpath}_previous"
    previous_base_file_tmp="_${fpath}_previous_tmp"

    rm -f $file_cover_result_file
    rm -f $previous_base_file_tmp

    total=0
    total_cover=0


    #cal percent
    while read file
    do
    	ls $file_cover_dir/${file}_notcover >/dev/null 2>/dev/null
    	if [ $? -eq 0 ];then
    	    not_cover=`wc -l $file_cover_dir/${file}_notcover | awk '{print $1}'`
    	else
    		not_cover=0
    	fi
    	ls $file_cover_dir/${file}_cover >/dev/null 2>/dev/null
    	if [ $? -eq 0 ];then
    		cover=`wc -l $file_cover_dir/${file}_cover | awk '{print $1}'`
    	else
    		cover=0
    	fi
    	all_cover=$[not_cover+cover]
    	if [ $all_cover -eq 0 ];then
    		percent=0
    	else
    		percent=`echo "scale=1;${cover}*100/$all_cover" | bc`
    	fi
    	total=$[total+all_cover]
    	total_cover=$[total_cover+cover]

    	echo "$file $cover $all_cover $percent" >> $file_cover_result_file
    done < $file_list
    percent=`echo "scale=1;$total_cover*100/$total" | bc`
    echo "Total $total_cover $total $percent" >> $file_cover_result_file

    #render_result_table_begin

    #Total
    render_Total_table_begin
    tail -1 $file_cover_result_file | while read file cover all_cover percent
    do
        if [ $all_cover -ne 0 ];then
        	cal_diff_previous "$file" "$percent" "$previous_base_file"
        	if [ $(echo "$diff_percent > 0"|bc) -eq 1 ];then
        		up_or_down=1
        	elif [ $(echo "$diff_percent == 0"|bc) -eq 1 ];then
        	    up_or_down=0
        	else
        		up_or_down=2
        	fi
            render_result_row_all "$file" "$cover" "$all_cover" "$percent" "$up_or_down" "$diff_percent"
            echo "$file $percent" >> $previous_base_file_tmp
        fi
    done
    render_result_table_end

    #Top risky
    generate_top_5_risky_files

    #All files
    render_result_table_begin
    tac $file_cover_result_file | while read file cover all_cover percent
    do
        if [ $all_cover -ne 0 ];then
    		cal_diff_previous "$file" "$percent" "$previous_base_file"
    		if [ $(echo "$diff_percent > 0"|bc) -eq 1 ];then
    			up_or_down=1
    		elif [ $(echo "$diff_percent == 0"|bc) -eq 1 ];then
    		    up_or_down=0
    		else
    			up_or_down=2
    		fi
    		if [ $file == "Total" ];then
    			nothing="do"
    		else
    	        render_result_row "$file" "$cover" "$all_cover" "$percent" "$up_or_down" "$diff_percent"
    	        echo "$file $percent" >> $previous_base_file_tmp
    	    fi
    	fi
    done
    
    render_result_table_end
    cp -f $previous_base_file_tmp $previous_base_file
}

function generate_top_5_risky_files()
{
	i=0
	#all_risky_files=`grep -v "^Total " $file_cover_result_file | sort -k4`
	render_TopRisk_table_begin
    grep -v "^Total " $file_cover_result_file | sort -k4 | while read file cover all_cover percent
    do
    	if [ $all_cover -ne 0 ];then
    	    if [ $i -lt 5 ];then
    		    render_result_row "$file" "$cover" "$all_cover" "$percent" "0" "0"
    		fi
    	    i=$[i+1]
    	fi
    done #< `grep -v "^Total " $file_cover_result_file | sort -k4`
    
    render_result_table_end
}

function generate_file_html()
{
	while read file
	do
		#render_file_div "$file"
		#render_file_table_head

        match_file_name="${file_cover_dir}/${file}_cover"
        notmatch_file_name="${file_cover_dir}/${file}_notcover"
        match_num=`wc -l $match_file_name 2>/dev/null| awk '{print $1}'`
        notmatch_num=`wc -l $notmatch_file_name 2>/dev/null| awk '{print $1}'`
        if [ -z $match_num ];then match_num=0;fi
        if [ -z $notmatch_num ];then notmatch_num=0;fi
        if [ $match_num -ne 0 ] || [ $notmatch_num -ne 0 ];then
        	render_file_div "$file"
        	render_file_table_head
        
            if [ -f $match_file_name ];then
                while read line
                do
                	echo "$line" | awk -F'%%%' '{print $1,$2,$3}' | while read line_num type log
                	do
                		render_file_table_row "$line_num" "${type}:${log}" 1
                	done
                done < $match_file_name
            fi
            if [ -f $notmatch_file_name ];then
                while read line
                do
                    echo "$line" | awk -F'%%%' '{print $1,$2,$3}' | while read line_num type log
                	do
                		render_file_table_row "$line_num" "${type}:${log}" 0
                	done
                done < $notmatch_file_name
            fi

		    render_file_table_tail
		fi
	done <$file_list
}

function generate_file_list()
{
	svn_url=$1
    svn co $svn_url
    #fpath=`echo $svn_url | awk -F"/" '{print $NF}'`
    fpath=`basename $svn_url`
    mv $fpath $tmp_dir
    nowpath=`pwd`
    mypath=$nowpath'/'$tmp_dir'/'$fpath
    echo $mypath
	find $mypath -regex "${file_type}" | grep -v ".*test_" | xargs egrep -H "(${log_type})" | awk -F':' '{print $1}' | sort |uniq | awk -F'/' '{print $NF}' |sort|uniq> $file_list
}

function generate_code_data()
{
	svn_url=$1
    fpath=`echo $svn_url | awk -F"/" '{print $NF}'`
    nowpath=`pwd`
    mypath=$nowpath'/'$tmp_dir'/'$fpath
    echo $mypath

    echo "begin to parse source code,please wait a second..."
    perl codeparser.pl $mypath "" > "$src_result"
    touch $code_process_ret
    #code_process_ret=0

}

function generate_log_data()
{
	#echo "call shfilter_log.sh $1 $log_temp_dir $file_list"
	sh filter_log.sh $1 $log_temp_dir $file_list
	if [ $? -ne 0 ];then
        #log_process_ret=1
		echo "WARNING!!!generate log data failed,exit"
		touch $log_process_fail
		exit -1
		#return $?
	fi
	#echo "call sh merge_log.sh $log_temp_dir $log_result"
	sh merge_log.sh $log_temp_dir $log_result
	if [ $? -ne 0 ];then
        #log_process_ret=2
		echo "WARNING!!!generate log data failed,exit"
		touch $log_process_fail
		exit -1
		#return $?
	fi
	touch $log_process_ret
}

function generate_cover_file()
{
	egrep "(${log_type})" $log_result > $wf_log_result
	while read line
	do
		echo "$line" | awk -F'%%' '{print $1,$2,$3,$4}' | while read file line_num type log
		do
		    match "$file" "$line_num" "$type" "$log"
		done
	done < $wf_log_result
}

function wait_to_analize_over()
{
	echo "begin wait analyze"
	while [ "1" == "1" ];do
		#finish_cnt=`ls $tmp_dir/*.ok 2>/dev/null | wc -l`
		#if [ $log_process_ret -eq 0 ] && [ $code_process_ret -eq 0 ];then
		if [ -f $log_process_ret ] && [ -f $code_process_ret ];then
            echo "analyze finished!"
			break
		else
			if [ -f $log_process_fail ];then
				echo "analyze log failed,please check log"
				exit -1
			fi
			let "run_time=run_time+1"
			sleep 1
		fi
		if [ $run_time -gt $timeout ];then
			echo "WARNING!!!!analyze time out,please check log"
			break
		fi
	done
	echo "end wait analyze"
}

function _deploy_script()
{
	machine_cnt=0
    for mac in $machines;do
	    echo "deploy script for $mac"
	    python remote_exe.py "ssh -n ${user}@${mac} \"mkdir -p $script_path\"" "$passwd"
	    python remote_exe.py "scp *.sh *.pl *.conf $file_list ${user}@${mac}:$script_path/" "$passwd"
	    machine_cnt=$[machine_cnt+1]
    done
}

function _analyse_one_machine()
{
	local mac=$1
    cmd="ssh -n ${user}@${mac} \"cd $script_path;sh analyse_remote_log.sh ${log_pathes} &\""
	python remote_exe.py "${cmd}" "$passwd"
}

function _analyse_remote_log()
{
    for mac in $machines;do
	    echo "analyse remote $mac log"
	    _analyse_one_machine $mac &
    done 
}

function _wait_remote_log_over()
{
	echo "wait for remote analyse over"
	local log_analyze_status="$tmp_dir/log_analyze_status"
	mkdir $log_analyze_status -p
	wait_time=0
    while [ "1" = "1" ];do
    	log_finish_cnt=`ls ${log_analyze_status}/*_analyze.ok 2>/dev/null| wc -l`
        if [ $log_finish_cnt -ne $machine_cnt ];then
            for mac in $machines;do
                python remote_exe.py "scp ${user}@${mac}:${script_path}/log_result/*_analyze.ok ${log_analyze_status}/ 2> /dev/null" $passwd
            done
            let "wait_time=wait_time+5"
            sleep 5
        else
            break
        fi
    
        if [ $wait_time -gt $timeout ];then
            log "wait time out wait_time:$wait_time wait_timeout:${timeout}s"
            echo "wait remote time out wait_time:$wait_time wait_timeout:${timeout}s"
            return 1
        fi
    done
    echo "finish waiting remote analyse over"
}

function _get_remote_log_result()
{
	echo "begin get remote log result"
	mkdir $remote_tmp_result_log -p
	for mac in $machines;do
		echo $mac
		python remote_exe.py "scp -r ${user}@${mac}:${script_path}/log_result/*.log ${remote_tmp_result_log}/${mac}.log" $passwd
	done
	sh merge_log.sh ${remote_tmp_result_log} $log_result
	echo "end get remote log result"
}

function remote_log_analyse()
{
    _deploy_script

	_analyse_remote_log

	_wait_remote_log_over

	_get_remote_log_result

    if [ $? -ne 0 ];then
		echo "WARNING!!!! get remote log failed,now exit"
		touch $log_process_fail
		exit -1
	fi

	touch $log_process_ret
}

function unittest()
{
	#fpath="petat_2_dev_BRANCH"
	fpath="cacheserver_1-0-48-1_PD_BL"
    render_result_head
    generate_total_html
    generate_file_html
    render_result_tail
}

function get_subject()
{
	while [ $# -gt 0 ];do
		if [[ "$1" == "-s" ]];then
			subject=$2
			shift
		fi
		shift
	done
}

function send_logcover_email()
{
    subject="logcover"

    get_subject "$@"
	
    while [ $# -ge 3 ];do
    	if [[ "$3" == "-s" ]];then
    		break
    	fi
        echo $3 | egrep '^\+?[a-z0-9](([-+.]|[_]+)?[a-z0-9]+)*@([a-z0-9]+(\.|\-))+[a-z]{2,6}$'
        ret=$?
        if [ $ret -eq 0 ];then
            send_email "result.html" $3 "${subject}"
        else
        	echo "WARNING!!!wrong email_address,please check,$ret"
        fi
        shift
    done
}

function main()
{
	[ $# -ge 3 ] || usage

	if [ $logcover_type -eq 0 ];then
		if [ -d "$2" ] ;then
		    echo "begin to run logcover"
	    else
	    	echo "WARNING!!!!can not find dir $2,exit"
	    	exit -1
	    fi
	fi

	clear_env

    echo "begin to generate file list..."
	generate_file_list $1 

    #echo "begin to generate code data..."
	generate_code_data $1 &

    echo "begin to generate log data..."

    if [ $logcover_type -eq 1 ];then
    	remote_log_analyse &
	    
	else
        generate_log_data $2 &
	fi

    echo "waiting code and log analyse finish..."
	wait_to_analize_over

    echo "begin to find coverage..."
	line_num=0
	while read line
    do
        #sh diff_one_line.sh "$line" &
        diff_one_line "$line" &
        line_num=$[line_num+1]
    done < $src_result
    for i in `seq 0 $line_num`
    do
    	wait
    done

    generate_cover_file

    echo "begin to generate html..."
    render_result_head
    generate_total_html
    generate_file_html
    render_result_tail

    echo "begin to send_email..."
    #send email with subject
    send_logcover_email "$@"
    

    #scp result.html work@cq01-testing-platqa2218.vm:/home/work/local/apache/htdocs

    #rm -rf $tmp_dir
    echo "succss"
}

#unittest

#generate_file_html
#generate_total_html

#wait_to_analize_over
main "$@"
#analyse_remote_log

#send_logcover_email "$@"
