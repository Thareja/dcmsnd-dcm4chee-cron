# dcmsnd-dcm4chee-cron
Cron Shell Script to upload DCM files to DCM4CHEE (PACS) server using the dcmsnd command. Tested on an Ubuntu 12.04 server.

This script was used for a mobile ultrasound company. They had many technicians who found it faster to zip and upload the studies to a server. The server would then run the cron script to unzip and push studies to the DCM4CHEE server. 
