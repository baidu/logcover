echo $1
echo $2
svn co $1
fpath=`echo $1 | awk -F"/" '{print $NF}'`
nowpath=`pwd`
mypath=$nowpath'/'$fpath
echo $mypath
echo $2
./codeparser.pl $mypath "">> "$2"
