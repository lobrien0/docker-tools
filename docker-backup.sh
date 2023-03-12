#!/bin/bash

#########################################################################################
# Program Data:										#
#											#
#	Author:		Luke O'Brien							#
#	Updated:	3/11/2023							#
#	Run as SU?:	YES								#
#											#
#	Reqired Packages:								#
#		p7zip-full								#
#											#
#	Description:									#
#		The following program will extract all the data from a exsisting	#
#		Docker container's image and volumes and export it into a sinlge 	#
#		'.7z' file								#
#											#
#	Why 7zip?:									#
#		I had chose to use 7zip instead of tar or gzip because 7zip 		#
#		offers a higher compression ratio and faster speeds a lot of		#
#		the time.								#
#											#
#########################################################################################

# Pulls the names of all active Docker containers into 'temp'
TEMP=$(docker ps -a --format "{{.Names}}")

# Check to see if there is input; error out if not
if [ $# -eq 0 ]; then
	echo "[-] No argument input..."
	echo "[ ] Please Enter the name of the container you want to backup"; echo
	exit 1

# Checks the input to see if Docker container with that name exsists
elif $(echo $TEMP | grep -Fwq "$1"); then

	# Defines Container name for rest of script
	ContainerName=$1
	
	# Captures each volume used by line in 'AllVol'
	AllVol=$(docker inspect $ContainerName | grep Source | sed -rn 's|.*/(.*)/_data.*|\1|p')

	mkdir $(pwd)/${ContainerName}-Dir

	# Loops through each volume, mapping the path to the data and archiving it
	# into a .7z file placed in the directory made for the backup
	for x in $AllVol; do
		VolMount=$(docker volume inspect --format '{{.Mountpoint}}' $x)
		7z a $(pwd)/${ContainerName}-Dir/${x}.7z ${VolMount}/*
	done

	# Captures the image name used by the container
	ContainerImage=$(docker inspect $ContainerName | sed -rn 's|.*"Image".*"(.*/.*)".*|\1|p')

	# Exports Image to temp backup directory
	docker save $ContainerImage -o $(pwd)/${ContainerName}-Dir/${ContainerName}.tar

	# Archives each volume and the image into a single 7zip file
	7z a $(pwd)/${ContainerName}.7z $(pwd)/${ContainerName}-Dir/*

	# Removes the temp directory
	rm -r $(pwd)/${ContainerName}-Dir

# Throws error if container name doesn't match exsisting Docker containers
else
	echo
	echo "[-] ${1}, is not an exsisting container..."; echo
fi

