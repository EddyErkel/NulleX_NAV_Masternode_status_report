#!/bin/bash
#
# Creator: Eddy Erkel
# Version: v0.4
# Date:    October 25, 2018
#
# This script can be used to check you NulleX NAV Masternode status
# This script will:
# - Verify NulleX masternode status
# - Verify NulleX block count
# - Verify NulleX balance at explorer.nullex.io
# - Verify NulleX installer version
# - Verify NulleX wallet version
# - Verify NulleX process ID
# - Verify number of running NulleX processes
# - Verify NulleX masternode server disk space
# - Verify NulleX masternode port connection
# - Send an email when an warning or error has been raised
#
#
# For more info about NulleX please go to https://nullex.io/
#
#
# This script uses SSMTP to send email:
# - SSMTP: https://help.ubuntu.com/community/EmailAlerts
# - SSMTP: https://wiki.archlinux.org/index.php/SSMTP
# - SSMTP config file: /etc/ssmtp/ssmtp.conf
#
# You can schedule this script via crontab
# - https://crontab.guru/
# - https://crontab.guru/examples.html
# - Run every hour:
#   0 * * * * /path/to/nullex/script/NulleX_NAV_status.sh
#
#
# Verify functions can be enabled, disabled and reordered at the bottom of this script
#
####################################################################################################


###################################################################################################
# Custom Variables (change if needed)
###################################################################################################
balanceinterval=720                                 # Minimum time expected between balance changes (in minutes)
filler="-"                                          # Character to fill header to same length
mailto="your.email@address.com"                     # Mail recipients separated by a space. Send result to when an alarm or error has been detected
mailsubject="NulleX NAV status report"              # Email subject
installfilegithub=https://raw.githubusercontent.com/NLXionaire/nullex-nav-installer/master/nullex-nav-installer.sh	# On-line NulleX NAV installation file
installfilelocal=~/nullex/nullex-nav-installer.sh   # Local NulleX NAV installation file which was used during set-up
nullexcli=/usr/local/bin/NulleX/nullex-cli          # nullex-cli path
pidfile=~/.nullexqt/NulleXd.pid                     # NulleX daemon process id file
masternodeport=43879								# Port used by NulleX masternode
processes=1                                         # Expected number of running nullexd processes
diskspace_alert=90									# set alert level 90% is default
# diskspace_excludelist="/dev/hdd1|/dev/hdc5"		# Exclude list of unwanted disk space monitoring, use "|" to separate the partitions. Not enabled by default.


###################################################################################################
# Default script variables
###################################################################################################
script_full=$( readlink -m $( type -p $0 ))         # Script file name including full path
script_dir=`dirname ${script_full}`                 # Script location path
script_name=`basename ${script_full}`               # Script file name without path
script_base="${script_name%.*}"                     # Script file name without extension
script_bal="$script_base.bal"                       # Script balance file
script_log="$script_base.log"                       # Script log file name
script_mail="$script_base.mail"                     # Script mail body
script_alert="$script_base.alert"                   # Alert file. Created when alert is raised
date_time="`date +%Y-%m-%d\ %H:%M:%S`"              # Set date variable
ssmtp=/usr/sbin/ssmtp                               # ssmtp path
warnings=0                                          # Set warnings to 0
errors=0                                            # Set errros to 0
checks=0											# Set checks to 0


###################################################################################################
# Functions
###################################################################################################
f_disphead ()
{
    len="76"
    string="$1"
    strlen=${#string}                               # ${#string} expands to the length of $string
    n_fill=$(( (len - $strlen - 2) / 2 ))
    
    echo -en "\e[92m"                               # Green text to screen
    
    printf "%${n_fill}s" | tr ' ' $filler
    echo -n " $string "

    printf "%${n_fill}s" | tr ' ' - >> $script_mail
    echo -n " $string ">> $script_mail

    if [ $((strlen%2)) -eq 0 ];
    then
        printf "%${n_fill}s\n" | tr ' ' $filler
        printf "%${n_fill}s\n" | tr ' ' $filler >> $script_mail
    else
        echo -n "-"
        printf "%${n_fill}s\n" | tr ' ' $filler
        echo -n "-">> $script_mail
        printf "%${n_fill}s\n" | tr ' ' $filler >> $script_mail
    fi

	echo -en "\e[0m"                                # Restore default color
}

f_dispfoot ()
{
    echo ""
	echo "" >> $script_mail
}

f_dispnorm ()
{
	echo -e "\e[39m$1\e[0m"	                        # Default text to screen
	echo "$1" >> $script_mail
}

f_dispwarn ()
{
	let warnings+=1
    echo -e "\e[93m$1\e[0m"                         # Yellow text to screen
#	echo -e "\e[38;5;202m$1\e[0m"                   # Orange text to screen
#	echo -e "\e[38;5;172m$1\e[0m"                   # Orange text to screen
	echo "$1" >> $script_mail
}

f_disperr ()
{
	let errors+=1
	echo -e "\e[91m$1\e[0m"	                        # Red text to screen
	echo "$1" >> $script_mail
}

f_alertset ()
{ 
	echo "$1" >> $alertFile                         # Write to file
}

f_alertclr ()
{
	rm -f $alertFile                                # Delete file
}


###################################################################################################
# Start mailbody
###################################################################################################
cd $script_dir
echo "Subject: $mailsubject" > $script_mail
echo "" >> $script_mail
echo $(date) >> $script_mail
echo "" >> $script_mail


###################################################################################################
# Display date and time
###################################################################################################
echo ""
echo $(date) 
echo ""


###################################################################################################
# Verify file variables
###################################################################################################
if ! [ -e $installfilelocal ] ; then f_disperr "File not found: $installfilelocal" ; exit; fi
if ! [ -e $nullexcli ] ; then f_disperr "File not found: $nullexcli" ; exit; fi
if ! [ -e $pidfile ] ; then f_disperr "File not found: $pidfile" ; exit; fi


###################################################################################################
# Verify masternode status
###################################################################################################
f_verify_masternode_status () {
	let checks+=1
    f_disphead "Verify NulleX masternode status"
    $nullexcli masternode status | grep message | sed -e "s/^  \"message\": //" 2>&1 | tee -a $script_mail
    masternodestatus=$($nullexcli masternode status | grep status | sed -e "s/^  \"status\": //" -e "s/,//")

    # masternodestatus=1                                  # Unhash for script testing
    
    if [ "$masternodestatus" == "4" ]; then
            f_dispnorm "NulleX masternode is running."
    else
            f_disperr "NulleX masternode is off-line."
    fi

    f_dispfoot
}


###################################################################################################
# Verify block count
###################################################################################################
f_verify_block_count () {
	let checks+=1
    f_disphead  "Verify NulleX block count"

    # Get block count at explorer.nullex.io
    expblockcount=$(wget -qO- https://explorer.nullex.io/api/getblockcount)
    f_dispnorm "Latest online block: $expblockcount"

    # Get NAV block count
    navblockcount=$($nullexcli getblockcount)
    f_dispnorm "Current local block: $navblockcount"

    # expblockcount=1                             # Unhash for script testing 
    # expblockcount=10000000000                   # Unhash for script testing
    
    if [ "$expblockcount" -eq "$navblockcount" ]; then
        f_dispnorm "NulleX masternode is in sync."
    else
	if [ "$expblockcount" -gt "$navblockcount" ]; then
	        f_dispwarn "NulleX masternode is out of sync!"
	else
		f_dispnorm "NulleX masternode is ahead of api getblockcount."
	fi
    fi

    f_dispfoot
}


###################################################################################################
# Verify balance
###################################################################################################
f_verify_balance () {
	let checks+=1
    # Create old file for testing:  touch -t YYYYMMDDhhmm.ss <filename>
    f_disphead "Verify NulleX balance at explorer.nullex.io"
    hash=$($nullexcli masternode status | grep "  \"addr\"" | sed -e "s/^  \"addr\": \"//" -e "s/\",//")

    newbalance=$(wget -qO- https://explorer.nullex.io/ext/getbalance/$hash | sed 's/\..*//')
    f_dispnorm "Checking balance online for $hash"
    if [ -f $script_bal ]; then
        oldbalance=$(cat $script_bal)
        datebalance=$(echo $(stat -c %y $script_bal) | sed 's/\..*//')
        balancechange=$(echo $(( $(date +%s) - $(stat -L --format %Y "$script_bal") > ($balanceinterval*60) )))
        f_dispnorm "Previous balance: $oldbalance"
        f_dispnorm "Current balance : $newbalance"
        
    # newbalance=1                                        # Unhash for script testing          
    # balancechange=1                                     # Unhash for script testing          
        
        if [ $newbalance -gt $oldbalance ]; then
            f_dispnorm "NulleX rewards have been added since previous check at $datebalance."
            echo "$newbalance" > $script_bal
        else
            if [ "$balancechange" -eq "1" ]; then
                f_dispwarn "NulleX balance change is taking longer than expected. Unchanged since $datebalance."
            else
                f_dispnorm "NulleX balance unchanged since previous check at $datebalance."
            fi
        fi
    else
        f_dispnorm "Current balance : $newbalance"
            echo "$newbalance" > $script_bal
    fi

    f_dispfoot
}


###################################################################################################
# Verify installer version
###################################################################################################
f_verify_installer_version () {
	let checks+=1
    f_disphead "Verify NulleX installer version"

    installerversion=$(wget -qO- $installfilegithub | grep '# Version:' | sed -e "s/^# Version: v//")
    f_dispnorm "NulleX masternode github installer version: $installerversion"

    installedversion=$(cat $installfilelocal | grep '# Version:' | sed -e "s/^# Version: v//")
    f_dispnorm "NulleX masternode local installed version : $installedversion"

    # installerversion=1                             # Unhash for script testing
    
    if [ "$installerversion" == "$installedversion" ]; then
            f_dispnorm "NulleX masternode installer version is correct."
    else
            f_dispwarn "NulleX masternode installer version is incorrect!"
    fi

    f_dispfoot
}


###################################################################################################
# Verify wallet version
###################################################################################################
f_verify_wallet_version () {
	let checks+=1
    f_disphead "Verify NulleX wallet version"
    latestwalletversion=$(wget -qO- $installfilegithub | grep '^WALLET_VERSION=\"' | sed -e "s/^WALLET_VERSION=\"//" -e "s/\"//")
    f_dispnorm "Github wallet version: $latestwalletversion"

    installedwalletversion=$($nullexcli | grep version | sed -e "s/^NulleX Core RPC client version v//" -e "s/-unk//")
    f_dispnorm "Local wallet version : $installedwalletversion"

    # latestwalletversion=1                             # Unhash for script testing
    
    if [ "$latestwalletversion" == "$installedwalletversion" ]; then
            f_dispnorm "NulleX wallet version is correct."
    else
            f_dispwarn "NulleX wallet version is incorrect!"
    fi

    f_dispfoot
}


###################################################################################################
# Verify process ID
###################################################################################################
f_verify_process_id () {
	let checks+=1
    f_disphead "Verify NulleX process ID"

    # pidfile=./test                                      # Unhash for script testing
    
    if [ -f $pidfile ]; then
        f_dispnorm "PID file $pidfile exists."
        f_dispnorm "Process ID: $(cat $pidfile)"
    else
            f_disperr "PID file $pidfile does NOT exist."
    fi

    f_dispfoot
}


###################################################################################################
# Verify number of running Nullex processes
###################################################################################################
f_verify_nullex_processes () {
	let checks+=1
    f_disphead "Verify number of running NulleX processes"
    processcount=$(ps -ef | grep nullexd | grep -v grep | wc -l)
    ps -ef | egrep 'PID|nullexd' | grep -v grep
    ps -ef | egrep 'PID|nullexd' | grep -v grep >> $script_mail
    
    # processcount=0                                      # Unhash for script testing    
    
    if [ "$processcount" == "$processes" ]; then
            f_dispnorm "Expected number of NulleX processes running ($processcount of $processes)."
    else
            f_dispwarn "Unexpted number of NulleX processes running ($processcount of $processes)."
    fi

    f_dispfoot
}


###################################################################################################
# Verify NulleX masternode server disk space
###################################################################################################
f_check_diskspace () {
	let checks+=1
	while read output;
		do
		  usep=$(echo $output | awk '{ print $1}' | cut -d'%' -f1)
		  partition=$(echo $output | awk '{print $2}')
		  if [ $usep -ge $diskspace_alert ] ; then
			f_dispwarn "Running out of space for \"$partition ($usep%)\""
		  fi
		done
	return $warnings
}

f_verify_diskspace () {
	let checks+=1
    f_disphead "Verify NulleX masternode server disk space"
	if [ "$diskspace_excludelist" != "" ] ; then
		df -H | grep -vE "^Filesystem|tmpfs|cdrom|${diskspace_excludelist}" | awk '{print $5 " " $6}' | f_check_diskspace
		local disk_warnings=$?
	else
		df -H | grep -vE "^Filesystem|tmpfs|cdrom" | awk '{print $5 " " $6}' | f_check_diskspace
		local disk_warnings=$?
	fi
	let warnings+=$disk_warnings
    if [ "$warnings" -eq 0 ]; then
		f_dispnorm "NulleX masternode server disk space is OK."
    fi	
	
	f_dispfoot
}


###################################################################################################
# Verify NulleX masternode port connection
###################################################################################################
f_check_port () {
	let checks+=1
	f_disphead "Verify NulleX masternode port connection"
	/bin/netstat -l | egrep -w "$masternodeport|Local Address" >> $script_mail
	/bin/netstat -l | grep -w "Local Address"
	/bin/netstat -l | grep -w "$masternodeport"
	if [ "$?" -ne 0 ]; then
		f_dispwarn "NulleX masternode is not listening on port $masternodeport."
	else
		f_dispnorm "NulleX masternode is listening on port $masternodeport."
	fi
	echo "" 2>&1 | tee -a $script_mail
	publicip=$(/usr/bin/wget -q -O - checkip.dyn.com|sed -e 's/.*Current IP Address: //' -e 's/<.*$//')
	#publicip=$(/usr/bin/curl -s ident.me)
	f_dispnorm "NulleX masternode external IP-address: $publicip"
	/bin/nc -z -v -w2 $publicip $masternodeport 2>&1 | tee -a $script_mail
	if [ "$?" -ne 0 ]; then
		f_disperr "Connection to $publicip on port $masternodeport failed."
	else
		f_dispnorm "Connection to $publicip on port $masternodeport succeeded."
	fi

	f_dispfoot
}


###################################################################################################
# Display summary
###################################################################################################
f_display_summary ()
{
    f_disphead "Summary"
	f_dispnorm "Checks  : $checks"
    f_dispnorm "Warnings: $warnings"
    f_dispnorm "Errors  : $errors"
	
	echo -e "\e[92m----------------------------------------------------------------------------\e[0m"
    f_dispfoot

}

    
###################################################################################################
# Write summary log file
###################################################################################################
f_write_logfile ()
{
    echo "$date_time   Block: $navblockcount   Balance: $newbalance   Warnings: $warnings   Errors: $errors" >> $script_log
}


###################################################################################################
# Send email
###################################################################################################
f_send_email ()
{
    if [ "$warnings" -gt 0 -o "$errors" -gt 0 ]; then # Sent email on warnings and errors
#    if [ "$errors" -gt 0 ]; then		      # Sent email on errors
        echo "Sending '$mailsubject' to $mailto"
        $ssmtp $mailto < $script_mail
    #	ssmtp $mailto -vvv < $script_mail	# Verbose ssmtp output
    fi

    f_dispfoot 
}


###################################################################################################
# Enable, disable and change verification order.
###################################################################################################
f_verify_masternode_status
f_verify_block_count
f_verify_balance
f_verify_installer_version
f_verify_wallet_version
f_verify_process_id
f_verify_nullex_processes
f_verify_diskspace
f_check_port
f_display_summary
f_write_logfile
f_send_email
