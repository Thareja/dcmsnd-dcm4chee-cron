#!/bin/bash

# Make sure only root can run our script
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root, please run 'sudo su' first" 1>&2
   exit 1
fi

LOG_FILE="/tmp/company_import_dcm.log"
LOCKFILE="/tmp/${0}.log"
UNZIP=/usr/bin/unzip
RM=/bin/rm



     echo "Health - PACS: DICOM Import Utility" 
     echo "Unauthorized Use Prohibited" 
     echo " " 


echo "Running As:"`whoami`  

# ************
# Add a quick check to see if another check is running
if [ -f "$LOCKFILE" ]; then
echo “Already running!”
exit
fi
echo Creating Lock File
touch "$LOCKFILE"

[ -x $UNZIP ] || { echo "No such executable: $UNZIP"; exit 1; }
[ -x $RM ] || { echo "No such executable: $RM"; exit 1; }


for zip in /bigdisk/company-upload/*.zip
do
file=$zip
file=$(basename "$zip")
echo "extracting: ${file%.*}" >> $LOG_FILE 2>&1

nice -n 19 cp "$zip" /bigdisk/company-upload/working/
nice -n 19 $UNZIP "$zip" -d "/bigdisk/company-upload/working/${file%.*}" >> $LOG_FILE 2>&1

if [ -d "/bigdisk/company-upload/working/${file%.*}" ]; then

echo "Started company DICOM IMPORT: "`date +%m/%d/%y\ %H:%M\ %Z` >> $LOG_FILE 2>&1

echo "Sending dicom files"  >> $LOG_FILE 2>&1
echo "  "  >> $LOG_FILE 2>&1
nice -n 19 /home/ubuntu/dcm4che-2.0.25/bin/dcmsnd -rspTO 180000  DCM4CHEE@localhost:11112 /bigdisk/company-upload/working/ >> $LOG_FILE 2>&1
nice -n 19 $RM -rf /bigdisk/company-upload/working/*
nice -n 19 mv "$zip" "/bigdisk/company-upload/done/"
echo "Finished company DICOM IMPORT: "`date +%m/%d/%y\ %H:%M\ %Z` >> $LOG_FILE 2>&1

mail -s "company Dicom Import log ${file%.*}  `date`" youremail@gmail.com < $LOG_FILE


fi

done


rm "$LOCKFILE"
rm "$LOG_FILE"

exit
