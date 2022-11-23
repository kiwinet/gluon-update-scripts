#!/bin/bash

##
## Config
##
MAIN_DIR="/opt/gluon-update-scripts-exp"

##
## Body
##
NEW="0"
source $MAIN_DIR/config.sh

BRANCH=$BRANCH_S

T="$(date +"%Y-%m-%d.%H%M")"
RELEASE_TAG="$GLUON_RELEASE.${BRANCH:0:1}.$T"
MY_RELEASE="${GLUON_RELEASE:1}-$BRANCH-$T"

{

if [ -d "$BASE_DIR/$BRANCH/gluon/output/images" ]; then
	if [ -d "$BASE_DIR/$BRANCH/gluon/output/images/sysupgrade" ]; then
		cd $BASE_DIR/$BRANCH/gluon/output/images/sysupgrade
		rm -f md5sums
		rm -f *.manifest
		md5sum * >> md5sums
	fi

	if [ -d "$BASE_DIR/$BRANCH/gluon/output/images/factory" ]; then
		cd $BASE_DIR/$BRANCH/gluon/output/images/factory
		rm -f md5sums
		rm -f *.manifest
		md5sum * >> md5sums
	fi

	echo "> make manifest"
	date
	cd $BASE_DIR/$BRANCH/gluon

	#/usr/bin/sudo -u $USER 
	make manifest GLUON_AUTOUPDATER_BRANCH=$BRANCH GLUON_AUTOUPDATER_ENABLED=1 GLUON_RELEASE=$MY_RELEASE

	cd $MAIN_DIR

	#/usr/bin/sudo -u $USER 
	$MAIN_DIR/sign.sh $MAIN_DIR/secret $BASE_DIR/$BRANCH/gluon/output/images/sysupgrade/$BRANCH.manifest

	cd $BASE_DIR/$BRANCH/gluon

	if [ -a "$BASE_DIR/$BRANCH/gluon/output/images/sysupgrade/$BRANCH.manifest" ]; then

		/bin/mkdir -p $HTML_IMAGES_DIR/../_archive/$BRANCH
		
		if [ -a "$HTML_IMAGES_DIR/../_archive/$BRANCH/images/sysupgrade/md5sums" ]; then
			/bin/more $HTML_IMAGES_DIR/$BRANCH/images/sysupgrade/md5sums >> $HTML_IMAGES_DIR/../_archive/$BRANCH/images/sysupgrade/md5sums
			/bin/rm -f $HTML_IMAGES_DIR/$BRANCH/images/sysupgrade/md5sums
		fi
		if [ -a "$HTML_IMAGES_DIR/../_archive/$BRANCH/images/factory/md5sums" ]; then
			/bin/more $HTML_IMAGES_DIR/$BRANCH/images/factory/md5sums >> $HTML_IMAGES_DIR/../_archive/$BRANCH/images/factory/md5sums
			/bin/rm -f $HTML_IMAGES_DIR/$BRANCH/images/factory/md5sums
		fi

		/bin/rm -f $HTML_IMAGES_DIR/$BRANCH/images/sysupgrade/$BRANCH.manifest
		/bin/cp -rf -t $HTML_IMAGES_DIR/../_archive/$BRANCH $HTML_IMAGES_DIR/$BRANCH/images
#		/bin/cp -rf -t $HTML_IMAGES_DIR/archive/$BRANCH $HTML_IMAGES_DIR/$BRANCH/modules

		/bin/rm -rf $HTML_IMAGES_DIR/$BRANCH/images

		/bin/mkdir -p $HTML_IMAGES_DIR/$BRANCH
		/bin/cp -rf -t $HTML_IMAGES_DIR/$BRANCH $BASE_DIR/$BRANCH/gluon/output/images
		/bin/cp -rf -t $HTML_IMAGES_DIR/$BRANCH $BASE_DIR/$BRANCH/gluon/output/modules
		/bin/cp -f $HTML_IMAGES_DIR/$BRANCH/images/sysupgrade/$BRANCH.manifest $HTML_IMAGES_DIR/$BRANCH/images/sysupgrade/$BRANCH-$T.manifest

		/bin/chown -R $USER:$USER $HTML_IMAGES_DIR
	fi

fi
} > >(tee -a /var/log/firmware-build/$MY_RELEASE-manifest.log) 2> >(tee -a /var/log/firmware-build/$MY_RELEASE-manifest.error.log | tee -a /var/log/firmware-build/$MY_RELEASE-manifest.log >&2)