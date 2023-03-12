#!/bin/bash
ContainerName=$(echo $1 | sed -rn 's|(.*)\.7z|\1|p')
7z x $(pwd)/$1 -o$(pwd)/${ContainerName}-Dir/
for x in $(pwd)/${ContainerName}-Dir/*.7z; do
	VolName=$(echo $x | sed -rn 's|.*/(.*)\.7z|\1|p')
	docker volume create $VolName
	VolPath=$(docker volume inspect --format '{{.Mountpoint}}' $VolName)
	7z x -o${VolPath}/ $x
	chown -R 1000:1000 ${VolPath}
	chmod -R 755 ${VolPath}
done

docker load -i $(pwd)/${ContainerName}-Dir/*.tar
rm -r $(pwd)/${ContainerName}-Dir

echo "----- ----- ----- -----"
echo "The Image, ${ContainerName}, and all its volumes have been created and uploaded to the system$(echo)"
echo "Now you must manually start the container"
echo
echo "----- ----- ----- -----"
