# NulleX_NAV_Masternode_status_report
#
# Creator: Eddy Erkel
# Version: v0.3
# Date:    October 24, 2018
#
# This script can be used to check you NulleX NAV Masternode status
# and send an report via email
# 
# For more info on NulleX please go to https://nullex.io/
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
# Verify functions can be enabled and disabled at the bottom of this script
#
####################################################################################################

Example output to the script:
------------------------------

Subject: NulleX NAV status report

Tue Oct 23 22:00:01 CEST 2018

--------------------- Verify NulleX block count ----------------------
Latest online block: 132700
Current local block: 132700
NulleX masternode is in sync.

------------------ Verify NulleX installer version -------------------
NulleX masternode github installer version: 1.0.6
NulleX masternode local installed version : 1.0.6
NulleX masternode installer version is correct.

-------------------- Verify NulleX wallet version --------------------
Github wallet version: 1.3.6.1
Local wallet version : 1.3.6.1
NulleX wallet version is correct.

------------------ Verify NulleX masternode status -------------------
NulleX masternode status is OK.

---------------------- Verify NulleX process ID ----------------------
PID file /home/user/.nullexqt/NulleXd.pid exists.
Process ID: 2938

------------- Verify number of running NulleX processes --------------
UID        PID  PPID  C STIME TTY          TIME CMD
user      2938     1  1 Oct05 ?        06:29:50 nullexd -resync
Expected number of NulleX processes running (1 of 1).

------------ Verify NulleX balance at explorer.nullex.io -------------
Checking balance online for Aa1Bb2Cc3Dd4Ee5Ff6Gg7Hh8Ii9Jj0KkLl
Previous balance: 50614
Current balance : 50614
NulleX balance unchanged since check at 2018-10-23 17:00:04.

------------------------------ Summary -------------------------------
Warnings: 0
Errors  : 0
