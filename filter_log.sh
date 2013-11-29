#/sbin/sh

function format_log(){
    line=$1 #key words
    log=$2
    dest_file=$3
	#get the log type,only for the log start [FATAL] or FATAL
    #the log format like "2013-05-08 12:31:14,058 ERROR..."(dc product line)
    if [[ `echo "${log}" |egrep "^[0-9]+\-[0-9]+\-[0-9]+" |wc -l` -eq 1 ]];then
        log_type=`echo "${log}" |awk -F ' ' '{print $3}'`
    else
        #for "15141   WARNING 06-07 00:00:01:418 [na_send.cpp:133][sendcode]return -1"
        if [[ `echo "${log}" |egrep "^[0-9]+" |wc -l` -eq 1 ]];then
             log_type=`echo "${log}" |awk -F ' ' '{print $2}'`
        else
            #the log format like [WARNING]...."
            if [[ "${log:0:1}" == "[" ]];then
                log_type=`echo "${log}" |awk -F ']' '{print $1}' |awk -F '[' '{print $2}'`
            #the log format like WARNING...."
            else
                log_type=`echo "${log}" | awk -F ':' '{print $1}'`
            fi
        fi
    fi

    #ccdb:*.cpp:line:thread
    str=`echo "$line" | egrep -o "[A-Za-z_]+:[A-Za-z_\./].*\.[A-Za-z]+:[0-9]+:[0-9]+"`
    if [[ ! -z $str ]];then
        #support ../*.cpp and *.cpp
        echo "`echo \"${line}\" |awk -F ':' '{print $2}'|awk -F '/' '{print $NF}'`%%`echo \"${line}\" |awk -F ':' '{print $3}'`%%${log_type}%%`echo \"${log}\" |grep -o \"\[.*\"`" >> ${dest_file}                
    else
         # target : *cpp:line
         str=`echo "$line" | egrep -o "[A-Za-z_\.].*\.[A-Za-z]+:[0-9]+L?"`
         if [[ ${#str} -ne 0 ]];then
             echo "${str//:/%%}%%${log_type}%%`echo \"${log}\" |grep -o \"\[.*\"`" >> ${dest_file}
         #*.cpp][line
         else
             str=`echo "$line" | egrep -o "[A-Za-z_\.].*\.[A-Za-z]+\]\[[0-9]+"`
             if [[ ${#str} -ne 0 ]];then
                echo "${str//][/%%}%%${log_type}%%`echo \"${log}\" |grep -o \"\[.*\"`" >> ${dest_file}
             #*.cpp:function:line_num
             else 
                 #*.cpp:function:line
                 str=`echo "$line" | egrep -o "[A-Za-z_\.].*\.[A-Za-z]+:.+:[0-9]+"`
                 if [[ ! -z $str ]];then 
                    echo "`echo \"${line}\" |awk -F ':' '{print $1"%%"$3}'`%%${log_type}%%`echo \"${log}\" |grep -o \"\[.*\"`" >> ${dest_file}
                 else 
                    #*.cpp:line:function
                    str=`echo "$line" | egrep -o "[A-Za-z_\.].*\.[A-Za-z]+:[0-9]+:.+"`
                    if [[ ! -z $str ]];then 
                        echo "`echo \"${line}\" |awk -F ':' '{print $1"%%"$2}'`%%${log_type}%%`echo \"${log}\" |grep -o \"\[.*\"`" >> ${dest_file}
                    else
                        #(*.*:function(line))
                        str=`echo "$line" | egrep -o "[A-Za-z_\.\-_0-9]+\.[A-Za-z]+:[A-Za-z_\.\-_0-9]+\([0-9]+\)"`
                        if [[ ! -z $str ]];then 
                            echo "`echo \"${line}\" |awk -F ':' '{print $1}'`%%`echo \"${line}\" |awk -F '(' '{print $2}'|awk -F ')' '{print $1}'`%%${log_type}%%\"${log}\"" >> ${dest_file}
                        else
                            #[*.*][function][line]
                            str=`echo "$line" |egrep -o "\]\[[a-zA-Z_0-9\-]+\]\[[0-9]+"`
                            if [[ ! -z $str ]];then 
                                echo "`echo \"${line}\" |awk -F ']' '{print $1}'`%%`echo \"${line}\" |awk -F '[' '{print $3}'`%%${log_type}%%\"${log}\"" >> ${dest_file}
                                                                
                            fi

                        fi
                    fi
                 fi
             fi

         fi
    fi
}


#-----------------------ENTRANCE------------------------------#
#--------------check param-------------------
#check param validation
if [[ $# -ne 3  ]] || [[ ! -d $1 ]] || [[ ! -f $3 ]];then
    echo "param is error,use:"
    echo "sh filter_log.sh log_directory result_directory code_list_file"
    exit -1
fi

log_path=$1
tmp_path=$2
src_code_files=$3

#dir complete
if [[ `expr match ${log_path} ".*/"` -eq 0 ]];then
    log_path="${log_path}/"
fi
if [[ `expr match ${tmp_path} ".*/"` -eq 0 ]];then
    tmp_path="${tmp_path}/"
fi

#--------------init----------------------------
log_files=`ls ${log_path}`

#rm the tmp file first
if [[ ! -e ${tmp_path} ]];then mkdir -p ${tmp_path};else rm -rf ${tmp_path}/* &>/dev/null;fi

#make sure the log file is exist
if [[ `ls ${log_path} |wc -l` -eq 0 ]];then
	echo "not find any log file"
	exit 1 
fi

#get the log key to temp file
for file in `cat ${src_code_files} `;do 
    #add [\[/] for del test_**.cpp
    #support
    #[*.*:lineL]
    #[*.*][line]
    #[*.*:line:function]
    #[*.*:function:line]
    #[*:*.*:line:thread]
    #(*.*:function(line)) for dc
    #[*.*:line]
    #[*.*][function][line]
    egrep -roh "[\[/]${file}:[0-9]+L?\]|[\[/]${file}\]\[[0-9]+\]|[\[/]${file}:[a-zA-Z_0-9\-]+:[0-9]+\]|[\[/]${file}:[0-9]+:[0-9a-zA-Z_\-]+\]|[\[][a-zA-Z_\-]+:[\./]*${file}:[0-9]+:[0-9]+\]|\(${file}:[0-9a-zA-Z_\-]+\([0-9]+\)\)|[\[/]${file}:[0-9]+\]|[\[/]${file}\]\[[a-zA-Z_0-9\-]+\]\[[0-9]+\]" ${log_path}/ >> ${tmp_path}/key_log
done

#make sure the key_log is existed
if [[ ! -s ${tmp_path}/key_log ]];then
	echo "not find any abnormal log"
	exit 1 
fi


sort ${tmp_path}/key_log  | uniq  > ${tmp_path}/key_log.uniq 

while read -r line;do
    #one_log=`sed -n "/${line:1}/{p;Q}" ${log_path}/*`
    #not show the file,delete the first and the last char of the key word
    one_log=`fgrep -rh "${line:1}" ${log_path} |head -n 1`
    if [[ ! -z ${one_log} ]]; then
        len=${#line}
        len=`expr $len - 2`
        format_log "${line:1:len}" "${one_log}"  "${tmp_path}/filter_log"
    fi
done < ${tmp_path}/key_log.uniq

rm ${tmp_path}/key_log
rm ${tmp_path}/key_log.uniq






