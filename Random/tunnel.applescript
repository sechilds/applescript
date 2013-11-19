do shell script "ssh -N schild2@eprirdc -L 8080/localhost/8080 &> /dev/null & echo $!"
set sshpid1 to the result
do shell script "ssh -N schild2@eprirdc -L 8889/localhost/8889 &> /dev/null & echo $!"
set sshpid2 to the result
do shell script "ssh -N schild2@eprirdc -L 6667/localhost/6667 &> /dev/null & echo $!"
set sshpid3 to the result
display dialog "ssh PIDs are: " & sshpid1 & " (port 8080), " & sshpid2 & " (port 8889), " & sshpid3 & " (port 6667)" buttons {"Close Tunnel"}
do shell script "kill -9 " & sshpid1
do shell script "kill -9 " & sshpid2
do shell script "kill -9 " & sshpid3
