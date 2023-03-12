#!/bin/bash

#########################################################################################
# Program Data:                                                                         #
#                                                                                       #
#       Author:         Luke O'Brien                                                    #
#       Updated:        3/11/2023                                                       #
#       Run as SU?:     YES                                                             #
#                                                                                       #
#       Reqired Packages:                                                               #
#               p7zip-full                                                              #
#                                                                                       #
#       Description:									#
#		Program will take an exsisting backup archive and restore the		#
#		volumes and image to docker engine on host				#
#                                                                                       #
#       Why 7zip?:                                                                      #
#               I had chose to use 7zip instead of tar or gzip because 7zip             #
#               offers a higher compression ratio and faster speeds a lot of            #
#               the time.                                                               #
#                                                                                       #
#########################################################################################


# Checks to see if there is input; erroring out if not
if [ $# -eq 0 ]; then
	echo "[-] No argument input..."
	echo "[ ] Please enter the filepath of the .7z container backup!"; echo
	exit 1

# Checks the input to make sure the file exsists
elif [ -f "$1" ]

	# Defines the name of the container based of file name
	ContainerName=$(echo $1 | sed -rn 's|(.*)\.7z|\1|p')

	# Extracts contents of 7zip file into a temporary directory
	7z x $1 -o$(pwd)/${ContainerName}-Dir/

	# Loops through all 7zip files just extracted into temp Directory
	for x in $(pwd)/${ContainerName}-Dir/*.7z; do
		
		# Defines volume name based on file name before creating volume in docker
		VolName=$(echo $x | sed -rn 's|.*/(.*)\.7z|\1|p')
		docker volume create $VolName

		# Defines mount point of volume and extracts all contents of 7z there.
		# Then sets file permisions to default user
		VolPath=$(docker volume inspect --format '{{.Mountpoint}}' $VolName)
		7z x -o${VolPath}/ $x
		chown -R 1000:1000 ${VolPath}
		chmod -R 755 ${VolPath}
	done

	# Loads container image into docker
	docker load -i $(pwd)/${ContainerName}-Dir/*.tar

	# Removes temp directory
	rm -r $(pwd)/${ContainerName}-Dir
	
	# Displays Process and gives user further instructions
	echo "----- ----- ----- -----"
	echo "The Image, ${ContainerName}, and all its volumes have been created and uploaded to the system$(echo)"
	echo "Now you must manually start the container"
	echo
	echo "----- ----- ----- -----"

# Errors out if File does not exsist
else
	echo "[-] Files doesn't exsist"
