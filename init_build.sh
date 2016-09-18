#!/bin/bash
##

source /opt/gluon-update-scripts/config.sh

if [[ -z "$1" || "$1" != 'stable' || "$1" != 'beta' || "$1" != 'experimental' ]]; then
	print 'stable, beta or experimental'
	exit 1
fi


if [ ! -d "$BASE_DIR" ]; then
	/bin/mkdir $BASE_DIR
fi

if [ ! -d "$BASE_DIR/$1" ]; then
	cd $BASE_DIR/$1
else
	/bin/mkdir $BASE_DIR/$1
fi

exit 1
git clone $REPO gluon -b $GLUON_RELISE
cd ./gluon
git clone $SITE_REPO site -b v2016.1.6

