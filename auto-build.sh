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
	/bin/su -u $USER $MAIN_DIR/init_build.sh $BRANCH
	NEW="1"
fi

if [ ! -d "$BASE_DIR/$BRANCH" ]; then
	/bin/su -u $USER $MAIN_DIR/init_build.sh $BRANCH
	NEW="1"
fi

if [ "$NEW" == '0' ]; then
	cd $BASE_DIR/$BRANCH/gluon
	/bin/su -u $USER git pull $REPO $GLUON_RELEASE
	if [ ! -d "$BASE_DIR/$BRANCH/gluon/site" ]; then
		/bin/su -u $USER git clone $SITE_REPO site -b $GLUON_RELEASE
	else
		cd $BASE_DIR/$BRANCH/gluon/site
		/bin/su -u $USER git pull $SITE_REPO $GLUON_RELEASE
	fi	
fi

cd $BASE_DIR/$BRANCH/gluon
/bin/su -u $USER make update
if [ "$NEW" == "0" ]; then
	/bin/su -u $USER make clean
fi
/bin/su -u $USER make -j2 GLUON_TARGET=ar71xx-generic GLUON_BRANCH=$BRANCH
/bin/su -u $USER make manifest GLUON_BRANCH=$BRANCH
/bin/su -u $USER ./contrib/sign.sh $SECRETKEY ./output/images/sysupgrade/$BRANCH.manifest

/bin/su -u $USER rm -rf $HTML_IMAGES_DIR
/bin/su -u $USER rm -rf $HTML_MODULES_DIR

/bin/su -u $USER cp -r ./output/images $HTML_MAIN_DIR
/bin/su -u $USER cp -r ./output/modules $HTML_MAIN_DIR

chown -R u1227:u1227 $HTML_MAIN_DIR
