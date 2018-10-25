<pre>
# NulleX_NAV_Masternode_status_report
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

Example script output:
----------------------

Subject: NulleX NAV status report

Thu Oct 25 20:50:19 CEST 2018

--------------------- Verify NulleX masternode status ----------------------
"Masternode successfully started"
NulleX masternode is running.

------------------------ Verify NulleX block count -------------------------
Latest online block: 135491
Current local block: 135491
NulleX masternode is in sync.

--------------- Verify NulleX balance at explorer.nullex.io ----------------
Checking balance online for Aa1Bb2Cc3Dd4Ee5Ff6Gg7Hh8Ii9Jj0KkLl
Previous balance: 50643
Current balance : 50679
NulleX rewards have been added since previous check at 2018-10-25 17:00:00.

--------------------- Verify NulleX installer version ----------------------
NulleX masternode github installer version: 1.0.6
NulleX masternode local installed version : 1.0.6
NulleX masternode installer version is correct.

----------------------- Verify NulleX wallet version -----------------------
Github wallet version: 1.3.6.1
Local wallet version : 1.3.6.1
NulleX wallet version is correct.

------------------------- Verify NulleX process ID -------------------------
PID file /home/userid/.nullexqt/NulleXd.pid exists.
Process ID: 2938

---------------- Verify number of running NulleX processes -----------------
UID        PID  PPID  C STIME TTY          TIME CMD
eddy      2938     1  1 Oct05 ?        07:23:06 nullexd -resync
Expected number of NulleX processes running (1 of 1).

---------------- Verify NulleX masternode server disk space ----------------
NulleX masternode server disk space is OK.

----------------- Verify NulleX masternode port connection -----------------
Proto Recv-Q Send-Q Local Address           Foreign Address         State
tcp        0      0 your.domain.name:43879  *:*                     LISTEN
NulleX masternode is listening on port 43879.

NulleX masternode external IP-address: 12.34.56.78
Connection to 12.34.56.78 43879 port [tcp/*] succeeded!
Connection to 12.34.56.78 on port 43879 succeeded.

--------------------------------- Summary ----------------------------------
Checks  : 9
Warnings: 0
Errors  : 0

</pre>
