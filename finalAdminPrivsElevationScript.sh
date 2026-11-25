#!/bin/bash
# SCRIPT DETAILS----------------------------------------------------------------------------------
# Name: 	adminPrivsElevationScript.zsh
# Date: 	19th November 2026
# Author:	Arun Patwardhan
# Email:	arun@amaranthine.co.in
# ------------------------------------------------------------------------------------------------

#LEGAL DISCLAIMER --------------------------------------------------------------------------------
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.
#-------------------------------------------------------------------------------------------------

#LICENSE/TERMS AND CONDITIONS --------------------------------------------------------------------
#MIT License

#Copyright (c) Amaranthine 2021.

#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:

#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.
#-------------------------------------------------------------------------------------------------

#ABOUT -------------------------------------------------------------------------------------------
# adminPrivsElevationScript.zsh
# 1.0
#-------------------------------------------------------------------------------------------------

#DESCRIPTION ------------------------------------------------------------------------------------- 
# - This script is intended for elevating the privieges for a user to **admin** for a limited period. 
# - Any user should be able to run this script.
# - This script can run on all computers.
# - The time options available are included in the preference file. It is expected that this is configured by the MDM. 
# - In case the MDM has not configured the file, then the script will automatically generate one with predefined values of
#   + 5 minutes
#   + 10 minutes
#   + 15 minutes
#   + 20 minutes
#-------------------------------------------------------------------------------------------------

#USAGE -------------------------------------------------------------------------------------------
# - Run the command: ./adminPrivsElevationScript.zsh
# - Available options  : Only the help option is available
# - Getting help       : Use the -h or the -help options to get more information.
#-------------------------------------------------------------------------------------------------

#WARNING/CAUTION ---------------------------------------------------------------------------------
#******************************************************************************************************************
#******************************************************************************************************************
#******************************************************************************************************************
#******************************************************************************************************************
# This script doesn't perform any validation. 
# If the script does not see the -h or the -help options then it will proceed with its intended action.
# The script must be run with sudo privileges.
# Please test the script before deploying
#******************************************************************************************************************
#******************************************************************************************************************
#******************************************************************************************************************
#******************************************************************************************************************
#-------------------------------------------------------------------------------------------------

#INSTALLATION ------------------------------------------------------------------------------------
# Instructions for placing the script in the correct place are listed here. 
# Location:		/Library/Scripts/
# Permissions:	rwx r-x r-x
#-------------------------------------------------------------------------------------------------

#REQUIREMENTS ------------------------------------------------------------------------------------
# Shell:		/bin/zsh
# OS:			macOS Golden Gate 27.0.1 or later
# Dependencies:	None
#-------------------------------------------------------------------------------------------------

#HELP/SUPPORT ------------------------------------------------------------------------------------
# You can get help by running the following commands.
# ./folderCreator.zsh -h
# ./folderCreator.zsh -help
# You can also view the log file for the same at: /Library/Logs/adminPrivelegesElevationScript_events.log
#-------------------------------------------------------------------------------------------------

#HISTORY -----------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------
# Version 1.0: Basic script which elevates privileges
#-------------------------------------------------------------------------------------------------

#-------------------------------------------------------------------------------------------------
# ------------------------------ SCRIPT STARTS HERE ----------------------------------------------
#-------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------

# Function ----------
function grantPrivilegesForShortTime() {
	echo "User $1, time $2"
	/usr/sbin/dseditgroup -o edit -a $1 -t user admin
	
	echo "[/bin/date "+%Y-%m-%d %H:%M:%S"] Privileges granted to user $1 for $2 seconds." >> $logFilePath
	/usr/bin/osascript << EOF
	display dialog "Privilege granted." buttons {"Ok"} with title "Admin Privileges Request." with icon POSIX file "/System/Applications/Clock.app/Contents/Resources/AppIcon.icns"
EOF
	
	/bin/sleep $2 
	/usr/sbin/dseditgroup -o edit -d $1 -t user admin
	
	echo "[/bin/date "+%Y-%m-%d %H:%M:%S"] Privileges withdrawn for user $1." >> $logFilePath
	
	/usr/bin/osascript << EOF
	display dialog "Privileges ended." buttons {"Ok"} with title "Admin Privileges Request." with icon POSIX file "/System/Applications/Clock.app/Contents/Resources/AppIcon.icns"
EOF
}

# Variables ----------
loggedInUser=$( /usr/sbin/scutil <<< "show State:/Users/ConsoleUser" | /usr/bin/awk '/Name :/ && ! /loginwindow/ { print $3 }' )
logFilePath="/Library/Logs/adminPrivelegesElevationScript_events.log"
preferenceFileLocation="/Library/Preferences/adminPrivilegesElevationScript_preferences.plist"

if [[ ! -f $preferenceFileLocation ]]; then
	/usr/bin/defaults write $preferenceFileLocation TimeDurationInMinutes -array-add "5" "10" "15" "20"
fi

/usr/bin/osascript << EOF
display dialog "Welcome to the Privilege Elevation app." buttons {"Proceed"} with title "Admin Privileges Request." with icon POSIX file "/System/Applications/Clock.app/Contents/Resources/AppIcon.icns"
EOF

echo "--------------------------------------------------" >> $logFilePath
# Tell the user that they will be getting permission as an admin for some time only. They can choose the time.
choice=$(/usr/bin/osascript << EOF
button returned of (display dialog "You are requesting access for admin privieges. This will be for a limited time only. Proceed only if you agree with these conditions." buttons {"Disagree", "Agree"} default button 2 with title "Admin Privileges Request." with icon POSIX file "/System/Library/CoreServices/Diagnostics Reporter.app/Contents/Resources/AppIcon.icns")
EOF
)
		
	echo "[/bin/date "+%Y-%m-%d %H:%M:%S"] User chose $choice" >> $logFilePath
		
if [[ $choice == "Agree" ]]; then
	# Get a count if the number of items in the array within the plist
	count=$(/usr/bin/defaults export $preferenceFileLocation - | /usr/bin/plutil -extract TimeDurationInMinutes raw -)
	
	echo "[/bin/date "+%Y-%m-%d %H:%M:%S"] The user is offered with $count options for time durations." >> $logFilePath
	
	# Collect the options available to the user in this variable
	options=""
	
	# Iterate over the plist array elements and generate the options to choose from
	nl=$'\n'
	for (( i = 0; i < $count; i++ )); do
		value=$(/usr/bin/defaults export $preferenceFileLocation - | /usr/bin/plutil -extract TimeDurationInMinutes."$i" raw -)
		echo "[/bin/date "+%Y-%m-%d %H:%M:%S"] OPTION $(($i + 1))) $value" >> $logFilePath
		if [[ $i == 0 ]]; then
			options="$value minutes"
		else
			options="$options${nl}$value minutes"
		fi
	done
	
	# Use the AppleScript script to offer the user a list based on the options we see above.
	timeDuration=$(/usr/bin/osascript - "$options" << 'EOF'
on run argv
set itemList to paragraphs of (item 1 of argv)
set userChoice to choose from list itemList with title "Time duration" with prompt "Please choose the time duration for which you need Admin Privileges. Note that once set this cannot be changed until the present duration is completed." 
if userChoice is false then return "false"
set selectedItem to item 1 of userChoice
return item 1 of userChoice
end run
EOF
)
			
	# Show what the user selected
	echo "[date "+%Y-%m-%d %H:%M:%S"] User selected: $timeDuration" >> $logFilePath
			
	if [[ $timeDuration == "5 minutes" ]]; then
		echo "[/bin/date "+%Y-%m-%d %H:%M:%S"] Give $loggedInUser admin privs for 5 minutes" >> $logFilePath
		grantPrivilegesForShortTime $loggedInUser 300
	elif [[ $timeDuration == "10 minutes" ]]; then
		echo "[/bin/date "+%Y-%m-%d %H:%M:%S"] Give $loggedInUser admin privs for 10 minutes" >> $logFilePath
		grantPrivilegesForShortTime $loggedInUser 600
	elif [[  $timeDuration == "20 minutes" ]]; then
		echo "[/bin/date "+%Y-%m-%d %H:%M:%S"] Give $loggedInUser admin privs for 20 minutes" >> $logFilePath
		grantPrivilegesForShortTime $loggedInUser 1200
	fi
else
	echo "[/bin/date "+%Y-%m-%d %H:%M:%S"] User decided not to elevate privileges." >> $logFilePath
fi
	
#-------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------
# ------------------------------ END OF SCRIPT ---------------------------------------------------