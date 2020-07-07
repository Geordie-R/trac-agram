#!/bin/bash
##################################################################################
##############  Origin Trail Logs To Telegram Message ############################
##################################################################################
████████╗██████╗  █████╗  ██████╗       █████╗  ██████╗ ██████╗  █████╗ ███╗   ███╗
╚══██╔══╝██╔══██╗██╔══██╗██╔════╝      ██╔══██╗██╔════╝ ██╔══██╗██╔══██╗████╗ ████║
   ██║   ██████╔╝███████║██║     █████╗███████║██║  ███╗██████╔╝███████║██╔████╔██║
   ██║   ██╔══██╗██╔══██║██║     ╚════╝██╔══██║██║   ██║██╔══██╗██╔══██║██║╚██╔╝██║
   ██║   ██║  ██║██║  ██║╚██████╗      ██║  ██║╚██████╔╝██║  ██║██║  ██║██║ ╚═╝ ██║
   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝      ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝
###################################################################################

# Welcome to TRAC-AGRAM by GeordieR. The purpose of this script is to notify a telegram bot
# when a new job is received.  The purpose may grow in future to cover errors etc but at the
# moment it is just new jobs

#Supports the following features
# I've been chosen and I've not been chosen statistics
# Send to telegram bot when new job received.  To add parameters please see the config file inside trac-agram folder.
# This script should be ran by a cron job.  see crontab -e command.
# This script is for running from the root directory/



#----------------------------------------------------------------------------------------------------#
# FUNCTIONS                                                                                          #
#----------------------------------------------------------------------------------------------------#
datenow=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

function set_config_value(){
  #This replaces a key-pair value
  paramname=$(printf "%q" $1)
  paramvalue=$(printf "%q" $2)

  #echo $paramname
  #echo $paramvalue
  sed -i -E "s/^($paramname[[:blank:]]*=[[:blank:]]*).*/\1$paramvalue/" "$config_file"
}

#----------------------------------------------------------------------------------------------------#
# get_config_value: GLOBAL VALUE IS USED AS A GLOBAL VARIABLE TO RETURN THE RESULT                                     #
#----------------------------------------------------------------------------------------------------#

function get_config_value(){
  global_value=$(grep -v '^#' "$config_file" | grep "^$1=" | awk -F '=' '{print $2}')
if [ -z "$global_value" ]
  then
    return 1
  else
    return 0
  fi
}


#----------------------------------------------------------------------------------------------------#
# PARAMETERS - AMENDABLE                                                                             #
#----------------------------------------------------------------------------------------------------#

monitor_dir="/root/tracnodemonitor"
this_script="nodemonitor.sh"

#----------------------------------------------------------------------------------------------------#
# PARAMETERS - DO NOT AMEND                                                                          #
#----------------------------------------------------------------------------------------------------#


#  THE CONFIG BELOW HAS NOTHING TO DO WITH YOUR NODE CONFIG FILE.
config_file="$monitor_dir/config"
set_config_value "last_ran" "$datenow"
phrase_chosen="I've been chosen"
phrase_not_chosen="I haven't been chosen"
telegram_chatid=""
telegram_token=""
datenow=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

set_config_value "last_ran" "$datenow"






#----------------------------------------------------------------------------------------------------#
# CREATE DIRECTORY IF IT DOESN'T EXIST                                                               #
#----------------------------------------------------------------------------------------------------#

if [ ! -d "$monitor_dir" ]
then
  mkdir -p "$monitor_dir"
  cp -p "$0" "$monitor_dir"
fi

#----------------------------------------------------------------------------------------------------#
# CREATE THE CONFIG FILE IF IT DOES NOT EXIST                                                        #
#----------------------------------------------------------------------------------------------------#

if [ ! -f "$config_file" ]
then
  echo "#Configuration file for the tracmonitor script" > "$config_file"
  echo "#Make the entries as variable=value" >> "$config_file"
  echo  >> "$config_file"
fi



















#----------------------------------------------------------------------------------------------------#
# COUNT # OF TIMES PHRASES FOUND IN THE LOGS                                                                          #
#----------------------------------------------------------------------------------------------------#

count_non_chosen=$(sudo docker logs otnode --tail 100000 | grep -c  "$phrase_not_chosen" | awk '{print $0}')
count_chosen=$(sudo docker logs otnode --tail 100000 | grep -c  "$phrase_chosen" | awk '{print $0}')
count_total=$(($count_chosen + $count_non_chosen))
echo "TOTAL JOBS $count_total"



get_config_value "last_chosen_job"
#Get last chosen job date from the config
last_chosen_job_config="$global_value"

#Now get last chosen job date from the logs
last_chosen_job=$(sudo docker logs otnode --tail 100000 | grep "$phrase_chosen" | awk '{print $1}' | tail -1)

#----------------------------------------------------------------------------------------------------#
# CHECK IF WE HAVE FOUND A NEW JOB BY COMPARING A PARAMETER                                                                         #
#----------------------------------------------------------------------------------------------------#



if [[ "$last_chosen_job" != "$last_chosen_job_config" ]] && [[ "$last_chosen_job_config" != "" ]]
then
send_message=true
new_job_msg="

-----------------
🆕 - New Job - 🆕
-----------------
You have won a new job: $last_chosen_job

"
fi

set_config_value "last_chosen_job" "$last_chosen_job"

#----------------------------------------------------------------------------------------------------#
# CREATE DIRECTORY IF IT DOESN'T EXIST                                                               #
#----------------------------------------------------------------------------------------------------#

if [ ! -d "$monitor_dir" ]
then
  mkdir -p "$monitor_dir"
  cp -p "$0" "$monitor_dir"
fi

#----------------------------------------------------------------------------------------------------#
# CREATE THE CONFIG FILE IF IT DOES NOT EXIST                                                        #
#----------------------------------------------------------------------------------------------------#

if [ ! -f "$config_file" ]
then
  echo "#Configuration file for the tracmonitor script" > "$config_file"
  echo "#Make the entries as variable=value" >> "$config_file"
  echo  >> "$config_file"
fi

#last_ran=$(cat $config_file | grep 'last_ran' | awk -F= '{print $2}')
#echo "last ran is: $last_ran"

#----------------------------------------------------------------------------------------------------#
# GET TELEGRAM TOKEN FROM THE USER OR TAKE IT FROM THE CONFIG FILE                                   #
#----------------------------------------------------------------------------------------------------#

if get_config_value "telegram_token"
then
  telegram_token="$global_value"
else
  if $at
  then
    exit 2
  fi
  read -p "COPY AND PASTE YOUR TELEGRAM TOKEN: " -e telegram_token
  echo "telegram_token=$telegram_token" >> "$config_file"
fi
echo "telegram token is $telegram_token"

#----------------------------------------------------------------------------------------------------#
# GET TELEGRAM CHAT ID FROM THE USER OR TAKE IT FROM THE CONFIG FILE                                 #
#----------------------------------------------------------------------------------------------------#

  if get_config_value "telegram_chatid"
  then
    telegram_chatid="$global_value"
  else
    if $at
    then
      exit 2
    fi
    read -p "COPY AND PASTE YOUR TELEGRAM CHAT ID: " -e telegram_chatid
    echo "telegram_chatid=$telegram_chatid" >> "$config_file"
    echo
  fi

send_message=false

#----------------------------------------------------------------------------------------------------#
# PREPARE NOTIFICATION TO SEND TO TELEGRAM                                                           #
#----------------------------------------------------------------------------------------------------#

get_config_value "nodename"
nodename="$global_value"

jobwinratio=$(echo "scale=3; ($count_chosen / $count_total)  *  100" | bc )

if [ ! -z "$telegram_chatid" ]
then
  telegram_message="
$new_job_msg
Ran Date: $(date +"%d-%m-%Y")
--------------------------
Job Stats For $nodename
--------------------------
Win Ratio: $jobwinratio%
$count_chosen chosen jobs and $count_non_chosen non chosen jobs
"

echo "telegram chat id isssss $telegram_chatid"
echo "telegram_message is $telegram_message"
#----------------------------------------------------------------------------------------------------#
# SEND ALERT NOTIFICATIONS TO TELEGRAM BOT (IF THERE'S SOMETHING TO SEND)                            #
#----------------------------------------------------------------------------------------------------#

  if $send_message
  then
    echo "trying to send through telegram"
    curl -s -X POST https://api.telegram.org/bot$telegram_token/sendMessage -d chat_id=$telegram_chatid -d text="$telegram_message" &>/dev/null
  fi
fi
