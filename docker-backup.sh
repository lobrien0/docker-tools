#!/bin/bash
ContainerName=$1
AllVol=$(docker inspect $ContainerName | grep Source | sed -rn 's|.*/(.*)/_data.*|\1|p')
mkdir $(pwd)/${ContainerName}-Dir
for x in $AllVol; do
	VolMount=$(docker volume inspect --format '{{.Mountpoint}}' $x)
	7z a $(pwd)/${ContainerName}-Dir/${x}.7z ${VolMount}/*
done
ContainerImage=$(docker inspect $ContainerName | sed -rn 's|.*"Image".*"(.*/.*)".*|\1|p')
docker save $ContainerImage -o $(pwd)/${ContainerName}-Dir/${ContainerName}.tar
7z a $(pwd)/${ContainerName}.7z $(pwd)/${ContainerName}-Dir/*
rm -r $(pwd)/${ContainerName}-Dir
