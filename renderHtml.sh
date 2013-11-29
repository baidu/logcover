###function r_he() 
#render the head of result about  html 
function render_result_head()
{
    rm -rf result.html
    begin='<html>
<head>
<title style="background:#f4f7fc;">LOGCOVER</title>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="http://fe/--todo"><font size=2>Feedback</font></a>
</head>
<body>
<div align=center><font color=blue size=6><br><strong>LOGCOVER-SUMMARY</strong></font></div>'   
 echo "$begin" >>result.html
}
function render_result_table_begin()
{
    tab_be='<table width=800 border="1" align=center cellspacing=0 style="border:1px solid #BEBEBE;">
<tr align=center><td width="40%" style="border:2px; background: #D2E9FF"><strong>All Files</strong></td><td colspan="1" width="14%" style="background: #D2E9FF;"><strong>Covered</strong></td><td colspan="1" style="background: #D2E9FF;" width="13%"><strong>Total WFlog</strong></td><td colspan="1" style="background: #D2E9FF;" width="15%"><strong>Coverage</strong></td><td colspan="1" style="background: #D2E9FF;" width="18%"><strong>Trend</strong></td></tr>'   
 echo "$tab_be" >>result.html
}
function render_Total_table_begin()
{
 tab_be='<table width=800 border="1" align=center cellspacing=0 style="border:1px solid #BEBEBE;"><tr align=center><td width="40%" style="border:2px; background: #D2E9FF"><strong>Total Coverage</strong></td><td colspan="1" width="14%" style="background: #D2E9FF;"><strong>Covered</strong></td><td colspan="1" style="background: #D2E9FF;" width="13%"><strong>Total WFlog</strong></td><td colspan="1" style="background: #D2E9FF;" width="15%"><strong>Coverage</strong></td><td colspan="1" style="background: #D2E9FF;" width="18%"><strong>Trend</strong></td></tr>'   
  echo "$tab_be" >>result.html
}
function render_TopRisk_table_begin()
{
  tab_be='<table width=800 border="1" align=center cellspacing=0 style="border:1px solid #BEBEBE;"><tr align=center><td width="40%" style="border:2px; background: #D2E9FF"><strong>Top Risky Files</strong></td><td colspan="1" width="14%" style="background: #D2E9FF;"><strong>Covered</strong></td><td colspan="1" style="background: #D2E9FF;" width="13%"><strong>Total WFlog</strong></td><td colspan="1" style="background: #D2E9FF;" width="15%"><strong>Coverage</strong></td><td colspan="1" style="background: #D2E9FF;" width="18%"><strong>Trend</strong></td></tr>'   
  echo "$tab_be" >>result.html
}
###function renderRow 
#$1:filename
#$2:coverrows
#$3total
#$4coverage
function render_result_row()
{
  if [[ "$5"x = "1"x ]]; then
         bground='"background: #00DB00;"'
         #arr='<font style="font-family: Wingdings 3">&#35;</font>'
         arr='<font face=Wingdings>&#241;</font>'
  else if [[ "$5"x = "2"x ]]; then
         bground='"background: #FF0000;"'
        #arr='<font style="font-family: Wingdings 3">&#36;</font>'
        arr='<font face=Wingdings>&#242;</font>'
  else 
         bground='"background: #FFED97;"'
           arr=''
  fi
  fi
 re='<tr align=center><td align=left width="40%" style="background: #FFED97;"><a href="#'$1'">'$1'</a></td><td colspan="1" style="background: #FFED97;" width="14%">'$2'</td><td colspan="1" width="13%" style="background: #FFED97;">'$3'</td><td colspan="1" style="background: #FFED97;" width="15%">'$4'%</td><td colspan="1" style='$bground' width="18%">'$arr' '$6'%</td></tr>'
    echo "$re" >>result.html
}
function render_result_row_all()
{
 if [[ "$5"x = "1"x ]]; then
          bground='"background: #00DB00;"'
          arr='<font face=Wingdings>&#241;</font>'
 else if [[ "$5"x = "2"x ]]; then
         bground='"background: #FF0000;"'
         arr='<font face=Wingdings>&#242;</font>'
 else
         bground='"background: #FFE66F;"'
         arr=''
 fi
 fi
 re='<tr align=center height="30px"><td align=left width="40%" style="background: #FFE66F;"><a href="#'$1'">'$1'</a></td><td colspan="1" style="background: #FFE66F;" width="14%">'$2'</td><td colspan="1" width="13%" style="background: #FFE66F;">'$3'</td><td colspan="1" style="background: #FFE66F;" width="15%">'$4'%</td><td colspan="1" style='$bground' width="18%">'$arr' '$6'%</td></tr>'
   echo "$re" >>result.html
}
                         
function render_result_table_end()
{ 
    echo '</table><br>'  >>result.html
}
function render_result_tail()
{
    ed='<br><div align=center><a href="http://wiki.babel.baidu.com/twiki/bin/view/Main/Log_cover"><font size=3>Loggcover  </font></a><font size=3>Powered by INF-DSQA<font></div></body>
</html>'
    echo "$ed">>result.html
}
##-------------------------the function about  render  file content html--------
##function f_be()
#----render the head of html
function render_file_div()
{
    echo '<div id='$1' align=center><font color=#019858 size=5><br><strong>'$1'</strong></font></div>'>>result.html
}
function render_file_table_head()
{
    msg='<table  width=800 border="1" align=center cellspacing=0 style="border:1px solid #D2E9FF;">
<tr align=center><td width="10%" style="border:1px; background: #D2E9FF"><strong>Line</strong></td><td colspan="1" width="80%" style="background: #D2E9FF;"><strong>WFlog</strong></td><td colspan="1" style="background: #D2E9FF;" width="10%"><strong>Result</strong></td></tr>'
    echo "$msg">>result.html
}


##function f_renderRow()
#-------
#$1 lineNo
#$2 content
#$3 iscover
function render_file_table_row()
{
##make diffrent color with diffrent result
    bground='"background: #FFE6FF;"'
    if [[ "$3"x = "1"x ]]; then
       result="T"
       bground='"background: #00DB00;"' 
    else
       result='F'
       bground='"background: #FF0000;"'
    fi
    re='<tr align=center><td width="10%" style="background: #FFF4C1;">'$1'</td><td align=left colspan="1" style="background: #FFF4C1;" width="80%">'$2'</td><td colspan="1" width="10%" style='$bground'>'$result'</td></tr>'
   echo "$re" >>result.html
}
function render_file_table_tail()
{
    echo "</table>" >>result.html
}

###this is a exmple function for render a  result html file 
function render_resultHtml()
{
    render_result_head 
    render_Total_table_begin
    render_result_row_all 'Total' 20 100 '20' 1 '10'
    render_result_table_end
    render_TopRisk_table_begin
    render_result_row 'b.cpp' 20 100 '20' 2 '10'
    render_result_row 'c.cpp' 20 100 '20' 1 '10'
    render_result_row 'd.cpp' 20 100 '20' 2 '10'
    render_result_table_end
    render_result_table_begin
    render_result_row 'e.cpp' 20 100 '20' 0 '0'
    render_result_row 'f.cpp' 20 100 '20' 1 '10'
    render_result_table_end

    render_file_div 'a.cpp'

    render_file_table_head
    render_file_table_row  100 'the log centent log centent' 1
    render_file_table_row  200 'the log centent log centent' 1
    render_file_table_row  200 'the log centent log centent' 0
    render_file_table_row  200 'the log centent log centent' 0
    render_file_table_row  200 'the log centent log centent' 0
    render_file_table_row  200 'the log centent log centent' 1
    render_file_table_tail
    render_file_div 'b.cpp'
    render_file_table_head
    render_file_table_row  100 'the log centent log centent' 1
    render_file_table_row  200 'the log centent log centent' 1
    render_file_table_row  200 'the log centent log centent' 1
    render_file_table_row  200 'the log centent log centent' 1
    render_file_table_row  200 'the log centent log centent' 1
    render_file_table_row  200 'the log centent log centent' 1
    render_file_table_tail
    render_result_tail
}

####function send_emain
#------send eail to
#$1  the file to send 
#$2  the destination
#$3  the name of subject
function send_email()
{
    cat $1 |formail -I "From: logcover@baidu.com" -I "MIME-Version:1.0" -I "Content-type:text/html;charset=gb2312" -I"Subject:""$3" -I "To:"$2|/usr/sbin/sendmail -oi $2 
 }
#render_resultHtml
#send_email "result.html" "liuqiang02@baidu.com" "bigpipe"
