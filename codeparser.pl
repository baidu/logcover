#! /usr/bin/perl

use Thread;
use warnings;
use strict;

my $argc=scalar(@ARGV);
our $path;
our $log_prefix;
if($argc eq 1){
	($path) = @ARGV;
	$log_prefix="";
}elsif($argc eq 2){
    ($path,$log_prefix)  = @ARGV ;
}else{
	die "wrong argument";
}
our $type="_WARNING|_FATAL|log.warning|LOG.warning|LOG.fatal|log.fatal|log.error|log.critical|CRITICAL|LOG.warn|WARNING_LOG|FATAL_LOG|logger.warn|log.warn|DSTREAM_WARN|DSTREAM_ERROR";
our $file_type=".*\\.\\(c\\|h\\|pl\\|cpp\\|php\\|py\\|java\\|cc\\)";
my @fileList = `find $path -regex "$file_type" | xargs egrep -H "${log_prefix}($type)" | awk -F':' '{print \$1}' | sort |uniq`;

#our $type="WARNING";
&main(@fileList);

sub parse_file()
{
    my ($single_file)=@_;

    #如果py的话不以;结尾，因此需要做适配
    my $tail;
    if($single_file =~ /.*\.py/){
    	$tail="";
    }else{
    	$tail=";";
    }

    my $openrs = open INPUT,"<",$single_file;
    if (! $openrs)
    {
        print "err open file $single_file \n";
    }
    my $lineNo = 0;
    my $log_buf;
    my $log_type;
    my $log_count=0;#log count in many line
        while(<INPUT>)
        {
            chomp;
            $lineNo++;
            my $baseName = `basename $single_file`;
            chomp $baseName;

            if($log_count eq 0 && $_ !~ /${log_prefix}($type)/){
            	next;
            }

            #这部分匹配以""作为日志的格式
            #匹配整行，以);结尾
            if (/${log_prefix}($type)\s*(,\s*|\().*\s*"(.*)".*\)$tail\s*(\s*|\\\s*)$/)#log_prefix log_type space(, or ()space"chars"chars);spaces$
            {
                print $baseName,"%%",$lineNo,"%%",$1,"%%",$3,"\n";
                next;
            }elsif(/${log_prefix}($type)\s*(,\s*|\()(\s*|.*)\s*"(.*?)(".*|"\s*,.*|"\),.*|"\s*,\s*\\|\\)\s*$/){
            #匹配部分行，标记log_count，收集日志
                $log_buf=$4;
                $log_count=1;
                $log_type=$1;
                next;
            }elsif(/${log_prefix}($type)\s*(,\s*|\()(\s*|\s*\\)\s*$/){
            	#第一次匹配到，初始化变量，用于下一次拼接日志
                $log_buf="";
                $log_count=1;
                $log_type=$1;
                next;
            }elsif($log_count gt 0){
            	#拼接日志
                if(/("|\\)(.*)"/){
                    $log_buf = "$log_buf"."$2";
                    $log_count+=1;
                }else{
                    $log_count+=1;
                }
                #找到日志结尾，打印具体日志信息
                if(/\)\s*$tail\s*(\\\s*|\s*)$/){
#print "can print now $lineNo\n";
                    print $baseName,"%%",$lineNo,"%%",$log_type,"%%",$log_buf,"\n";
                    $log_count=0;
                    $log_type="";
                    $log_buf="";
                }
                next;
            }

            #这部分匹配以''作为日志的格式，与上面类似
            if (/${log_prefix}($type)\s*(,\s*|\().*\s*'(.*)'.*\)$tail\s*(\s*|\\\s*)$/)#log_prefix log_type space(, or ()space"chars"chars);spaces$
            {
                print $baseName,"%%",$lineNo,"%%",$1,"%%",$3,"\n";
            }elsif(/${log_prefix}($type)\s*(,\s*|\()(\s*|.*)\s*'(.*?)('.*|'\s*,.*|'\),.*|'\s*,\s*\\|\\)\s*$/){
            #匹配部分行，标记log_count，收集日志
                $log_buf=$4;
                $log_count=1;
                $log_type=$1;
            }elsif(/${log_prefix}($type)\s*(,\s*|\()(\s*|\s*\\)\s*$/){
                $log_buf="";
                $log_count=1;
                $log_type=$1;
            }elsif($log_count gt 0){
                if(/('|\\)(.*)'/){
                    $log_buf = "$log_buf"."$2";
                    $log_count+=1;
                }else{
                    $log_count+=1;
                }
                if(/\)\s*$tail(\\\s*|\s*)$/){
#print "can print now $lineNo\n";
                    print $baseName,"%%",$lineNo,"%%",$log_type,"%%",$log_buf,"\n";
                    $log_count=0;
                    $log_type="";
                    $log_buf="";
                }
            }
        }
    close INPUT;
}

sub main()
{
    my @files = @_;
    my $file_num=scalar(@files);
    my @threads;
    my $thread_id=0;

    foreach my $single_file (@files)
    {
      chomp $single_file;
      $threads[$thread_id]=Thread->new(\&parse_file,$single_file);
      $thread_id++;
    }
    foreach my $thread (@threads) {
    	$thread->join();
    }
}

