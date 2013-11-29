sh checklog.sh https://xxx  data.txt
sh filter_log.sh ./testlogs/ ./result/
sh merge_log.sh ./result/ filter.log 
sh logdiff.sh
scp result.html user@mac:dir
