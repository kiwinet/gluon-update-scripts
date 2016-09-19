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
##
## clone GLUON
##
git clone $REPO gluon -b $GLUON_RELEASE
git checkout $GLUON_RELEASE

cd $BASE_DIR/$1/gluon

/bin/rm -rf $BASE_DIR/$1/gluon/site
##
## clone SITE config
##
git clone $SITE_REPO site -b $GLUON_SITE_RELEASE
git checkout $GLUON_SITE_RELEASE
