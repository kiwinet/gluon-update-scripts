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
	git checkout $GLUON_RELEASE
	git pull $REPO $GLUON_RELEASE

	sleep 3

	if [ ! -d "$BASE_DIR/$BRANCH/gluon/site" ]; then
		git clone $SITE_REPO site
		git checkout $GLUON_RELEASE
		git pull
	else
		cd $BASE_DIR/$BRANCH/gluon/site
		/bin/rm -f ./README.md
		git checkout $GLUON_RELEASE
		git pull $SITE_REPO $GLUON_RELEASE
	fi	
fi
cd $BASE_DIR/$BRANCH/gluon
exit 1
sleep 3

for TARGET in $TARGETS $TARGETSx86
do
	make clean GLUON_TARGET=$TARGET
done

make update

sleep 3

for TARGET in $TARGETS
do
	date
	make -j $THREADS GLUON_TARGET=$TARGET GLUON_BRANCH=$BRANCH
done

make manifest GLUON_BRANCH=$BRANCH
./contrib/sign.sh $SECRETKEY ./output/images/sysupgrade/$BRANCH.manifest

/bin/rm -rf $HTML_IMAGES_DIR

/bin/mkdir -p $HTML_IMAGES_DIR
/bin/cp -r ./output/images $HTML_IMAGES_DIR
/bin/cp -r ./output/modules $HTML_IMAGES_DIR

/bin/chown -R $USER:$USER $HTML_IMAGES_DIR
