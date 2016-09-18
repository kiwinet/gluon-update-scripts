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


# Show summery
date

echo "Targets: $TARGETS"
echo "Futro ??? Targets: $TARGETSx86"
echo "Using $THREADS Cores"

sleep 5 

if [ "$NEW" == '0' ]; then
	cd $BASE_DIR/$BRANCH/gluon
	git checkout master
	git pull
	git checkout $GLUON_RELEASE

	sleep 3

	git pull $REPO $GLUON_RELEASE
	if [ ! -d "$BASE_DIR/$BRANCH/gluon/site" ]; then
		git clone $SITE_REPO site -b $GLUON_RELEASE
	else
		cd $BASE_DIR/$BRANCH/gluon/site
		/bin/rm -f ./README.md
		git pull $SITE_REPO $GLUON_RELEASE
	fi	
fi
exit 1
cd $BASE_DIR/$BRANCH/gluon
make update
if [ "$NEW" == "0" ]; then
	make clean
fi
make -j$THREADS GLUON_TARGET=$TARGETS GLUON_BRANCH=$BRANCH
make manifest GLUON_BRANCH=$BRANCH
./contrib/sign.sh $SECRETKEY ./output/images/sysupgrade/$BRANCH.manifest

/bin/rm -rf $HTML_IMAGES_DIR

/bin/mkdir -p $HTML_IMAGES_DIR
/bin/cp -r ./output/images $HTML_IMAGES_DIR
/bin/cp -r ./output/modules $HTML_IMAGES_DIR

/bin/chown -R $USER:$USER $HTML_IMAGES_DIR
