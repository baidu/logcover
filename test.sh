sh checklog.sh https://svn.baidu.com/inf/ds/branches/transkeeper/master/dev_2-0-0_BRANCH  data.txt
sh filter_log.sh ./testlogs/ ./result/
sh merge_log.sh ./result/ filter.log 
sh logdiff.sh
scp result.html work@cq01-testing-platqa2218.vm:~/local/apache/htdocs
