#!/bin/bash
##

source /opt/gluon-update-scripts/config.sh

if [ -z "$1" ]; then
	echo 'stable, beta or experimental 1'
	exit 1
fi

if [ ! -d "$BASE_DIR" ]; then
	/bin/mkdir -p $BASE_DIR
fi

if [ ! -d "$BASE_DIR/$1" ]; then
	/bin/mkdir -p $BASE_DIR/$1
fi

cd $BASE_DIR/$1
git clone $REPO gluon
git checkout $GLUON_RELEASE
git pull
#git clone $REPO gluon -b $GLUON_RELEASE

cd ./gluon

/bin/rm -rf ./site
git clone $SITE_REPO site
git checkout $GLUON_RELEASE
git pull
#git clone $SITE_REPO site -b $GLUON_RELEASE
