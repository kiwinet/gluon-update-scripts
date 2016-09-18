#!/bin/bash

##
## Config
##
MAIN_DIR="/opt/gluon-update-scripts"

##
## Body
##
NEW="0"
source $MAIN_DIR/config.sh

cd $MAIN_DIR

if [ ! -d "$BASE_DIR" ]; then
	$MAIN_DIR/init_build.sh $BRANCH
	NEW="1"
fi

if [ ! -d "$BASE_DIR/$BRANCH" ]; then
	$MAIN_DIR/init_build.sh $BRANCH
	NEW="1"
fi

if [ "$NEW" == '0' ]; then
	cd $BASE_DIR/$BRANCH/gluon
	git pull $REPO $GLUON_RELEASE
	if [ ! -d "$BASE_DIR/$BRANCH/site" ]; then
		git clone $SITE_REPO site -b $GLUON_RELEASE
	else
		cd $BASE_DIR/$BRANCH/site
		git pull $REPO $GLUON_RELEASE
	fi	
fi

cd $BASE_DIR/$BRANCH/gluon
make update
if [ "$NEW" == "0" ]; then
	make clean
fi
make -j2 GLUON_TARGET=ar71xx-generic GLUON_BRANCH=$BRANCH
make manifest GLUON_BRANCH=$BRANCH
./contrib/sign.sh $SECRETKEY ./output/images/sysupgrade/$BRANCH.manifest

rm -rf $HTML_IMAGES_DIR
rm -rf $HTML_MODULES_DIR

cp -r ./output/images $HTML_MAIN_DIR
cp -r ./output/modules $HTML_MAIN_DIR

chown -R u1227:u1227 $HTML_MAIN_DIR
