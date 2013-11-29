#/sbin/sh
#--------------param check------------------------------------#
#if [[ $# -ne 2  ]] || [[ ! -d $1 ]] ||[[ `expr match $2 ".*/$"` -gt 0 ]];then
src_filter_log_path=$1
dst_log=$2

if [[ $# -ne 2  ]] || [[ ! -d $1 ]] ||[[ "${dst_log:(-1)}"x = "/"x ]];then
    echo "param is error,use:"
    echo "sh merge_log.sh filter_log_directory resut_file"
    exit -1
fi


#dir complete
#if [[ `expr match ${src_filter_log_path} ".*/"` -eq 0 ]];then
#   src_filter_log_path="${src_filter_log_path}/"
#fi

#clean dst_log_file
if [[ -e ${dst_log} ]];then  rm  ${dst_log} ;fi

#if only one file
#if [[ `ls ${src_filter_log_path} |wc -l` -eq 1 ]];then
#    cp ${src_filter_log_path}/`ls ${src_filter_log_path}` ${dst_log}
#    exit
#fi

tmp_merge_log="_tmp_merge_log"
tmp_merge_log_uniq="_tmp_merge_log.uniq"

#get all the log key word from the result of filter_log.sh and then sort
egrep -roh ".*\.[A-Za-z0-9_\-]+%%[0-9]+L?%%" ${src_filter_log_path}/ > ${tmp_merge_log}
sort ${tmp_merge_log} |uniq  > ${tmp_merge_log_uniq} 

#get the log by tmp file
while read -r line;do
    one_log=`fgrep -rh "${line}" ${src_filter_log_path}/ |head -n 1`
    if [[ ! -z ${one_log} ]]; then
        echo "${one_log}" >> ${dst_log}
    fi
done < ${tmp_merge_log_uniq} 


rm ${tmp_merge_log}
rm ${tmp_merge_log_uniq} 


