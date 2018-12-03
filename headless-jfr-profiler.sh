#!/bin/bash 

################################################################################
# Script to turn on 'Java Flight Recording' for a given process.               #
# Author: Amit K. Sharma (amit.official@gmail.com)                             #
################################################################################

name=$1

if [ "$name" == "" ] || [ "$name" == "-h" ] || [ "$name" == "--help" ]
    then 
    echo -e "Usage: headless-jfr-profiler.sh {java-component-name} \
{recording duration in mins} \nWhere: {recording duration in mins} \
is optional and defaults to 30 mins"
    exit -1
fi

duration_in_mins=$2
if [ "$duration_in_mins" == "" ]
    then 
    duration_in_mins=30
fi
duration_in_secs=$((${duration_in_mins}*60))

echo "------------------------------------------------"
#figure out the pid of the java process
process=`jcmd | grep -i ${name} | head -1`
echo "* Identified process: ${process}"
pid=`echo ${process} | cut -d' ' -f1`
echo "* Identified pid: ${pid}"
echo "* Recording duration (mins): ${duration_in_mins}"
echo "* Save on process exit: Yes"
jfr_name="${name}_`hostname`_`date +%d-%b-%Y-%H%M%S`"
echo "* JFR name: ${jfr_name}"
jfr_filename="${HOME}/${jfr_name}.jfr"
echo "* JFR file path: ${jfr_filename}"
echo "------------------------------------------------"

if [ "${pid}" == "" ] 
    then
    echo "** No pid could be found with given 'java-component-name'. Aborting! **"
    echo "(Are you sure the process is running ?)"
    echo 
    exit
fi

echo ">> Continue? [y/n]"
while true; do
    read -p "Do you wish to install this program?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer y or n.";;
    esac
done

echo "------------------------------------------------"
echo ">> Unlocking commercial features for pid ${pid} ..."
jcmd ${pid} VM.unlock_commercial_features
echo "------------------------------------------------"
echo ">> Verifying commercial features for pid ${pid} ..."
jcmd ${pid} VM.check_commercial_features
echo "------------------------------------------------"
echo ">> Starting JFR for ${pid} ..."
jcmd ${pid} JFR.start name=${jfr_name} filename=${jfr_filename} \
duration=${duration_in_mins}m dumponexit=true compress=true
echo "------------------------------------------------"
echo ">> Verifying JFR for ${pid} ..."
jcmd ${pid} JFR.check #To check the status
echo "------------------------------------------------"
