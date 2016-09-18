#!/bin/bash
##

source /opt/gluon-update-scripts/config.sh

if [ -z "$1" ]; then
	print 'stable, beta or experimental 1'
	exit 1
fi


if [ ! -d "$BASE_DIR" ]; then
	/bin/mkdir $BASE_DIR
fi

if [ ! -d "$BASE_DIR/$1" ]; then
	/bin/mkdir $BASE_DIR/$1
fi

cd $BASE_DIR/$1
git clone $REPO gluon -b $GLUON_RELISE

cd ./gluon
git clone $SITE_REPO site -b $GLUON_RELISE

