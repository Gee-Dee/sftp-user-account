#!/bin/bash
# 2016-0330 - usercheck.sh - check sftp user attributes (account expiry, user files).  If the user's attributes are past 90 days report it.

# To-do:
# automatically download sftp-users, sshd.log files to work on locally.

#set -x
#YYMMA=`date +%Y%m -d "-90days"` # Linux only
#YYMMB=`date +%Y%m -d "-45days"` # Linux only
#YYMMC=`date +%Y%m -d "-15days"` # Linux only
YYMMA=`date -j -v-90d +"%Y%m"` # OSX only
YYMMB=`date -j -v-45d +"%Y%m"` # OSX only
YYMMC=`date -j -v-15d +"%Y%m"` # OSX only
#SSH_LOG="/var/log/sftp"
SSH_LOG="/Users/jddelacr/Documents/Projects/2016/SFTP-cleanup"
RUN_DATE=`date +%Y-%m%d-%H%M-%S`
SEARCH_DIR="/usr/local/sftp_root"
USER_CHK_LOG="logs/usercheck-$RUN_DATE.log"

#grep sftp_root /etc/passwd | cut -d: -f1 >> config/sftp-user-list.txt

for Uname in `cat config/sftp-user-list.txt | cut -d: -f1`
do
	echo "------------" >> $USER_CHK_LOG
	# Determine log files to search for the past 90/45/15 days:
	for LogFile in `ls sshd.log-$YYMMA*`
	do
		grep $SEARCH_DIR $LogFile | grep -q $Uname
	
		if [ $? -eq 0 ]
		then
			YYMMAGroup=true
			echo "$Uname past 90 days activity: $LogFile" >> $USER_CHK_LOG
		else
			echo "$Uname past 90 days activity: None" >> $USER_CHK_LOG
		fi
		
		if [[ $YYMMAGroup == true ]]
		then
			break
		fi
	done

	echo "">> $USER_CHK_LOG
	for LogFile in `ls sshd.log-$YYMMB*`
	do
       		 grep $SEARCH_DIR $LogFile | grep -q $Uname

        	if [ $? -eq 0 ]
        	then
        		YYMMBGroup=true
			echo "$Uname past 45 days activity: $LogFile" >> $USER_CHK_LOG
        	else
			echo "$Uname past 45 days activity: None" >> $USER_CHK_LOG
        	fi
        	
        	if [[ $YYMMBGroup == true ]]
		then
			break
		fi
	done

	echo "">> $USER_CHK_LOG
	for LogFile in `ls sshd.log-$YYMMC*`
	do
       		 grep $SEARCH_DIR $LogFile | grep -q $Uname

        	if [ $? -eq 0 ]
        	then
        		YYMMCGroup=true
			echo "$Uname past 15 days activity: $LogFile" >> $USER_CHK_LOG
        	else
			echo "$Uname past 15 days activity: None" >> $USER_CHK_LOG
        	fi
        	
        	if [[ $YYMMBGroup == true ]]
		then
			break
		fi
	done
	echo "------------" >> $USER_CHK_LOG
done

# Search for the user's directory then the files associated with that user.
#for Uname in `cat config/sftp-user-list.txt`
#do
#	echo "------------" >> $USER_CHK_LOG
#	Uname_Dir=`find $SEARCH_DIR -name $Uname`
#	echo "SFTP User: $Uname: Files (-mtime +90 days):" >> $USER_CHK_LOG
#	find $Uname_Dir -type f -mtime +90 >> $USER_CHK_LOG
#	echo "------------" >> $USER_CHK_LOG
#done
