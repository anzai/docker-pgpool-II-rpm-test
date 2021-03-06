#! /bin/bash
#
# Main driver to generate rpms
# $0: [-p proxy_address]
# if "-p" is specifed, proxy setting used.
#

# Directory to place result rpms/srpms. Default to
# your_home_directory/volum.
myvol=$HOME/volum

# Docker image file name.
image=pgpool2_test_rpm_centos6

# pgpool-II versions
export pgpool_II_versions="3.4.1 3.3.5"
# rpm versons (corresponding to pgpool-II versions)
export rpm_versions=(3 3)

# PostgreSQL version
postgresql_versions="92 93 94"

if [ $# -gt 1 ];then
    if [ $1 = "-p" ];then
	proxy=$2
	proxy_set=y
	echo "inserting proxy address $2."
    else
	echo "wrong parameter $1".
	exit 1
    fi
else
    proxy_set=n
fi

echo "======= Start docker build ======="
if [ $proxy_set = "y" ];then
    cp Dockerfile Dockerfile.orig
    cat Dockerfile|sed "/ENV/ aENV http_proxy $proxy" > Dockerfile.proxy
    cp Dockerfile.proxy Dockerfile
    #exit
else
    sudo docker build -t $image .
fi
    sudo docker build -t $image .

echo "======= End docker build ======="

if [ $proxy_set = "y" ];then
    cp Dockerfile.orig Dockerfile
fi

for i in $postgresql_versions
do
    index=0
    for j in $pgpool_II_versions
    do
	echo "======= Start rpm install test for pgpool-II $j PostgreSQL $i ======="
	sudo docker run --rm -e PGPOOL_VERSION=$j -e POSTGRESQL_VERSION=$i -e RPM_VERSION=${rpm_versions[$index]} -v $myvol:/var/volum -t $image
	echo "======= End rpm install test for pgpool-II $j PostgreSQL $i ======="
	index=`expr $index + 1`
    done
done
