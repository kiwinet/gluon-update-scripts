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

BRANCH=$BRANCH_S

T="$(date +"%Y%m%d_%H:%M")"
RELEASE_TAG="$GLUON_RELEASE.${BRANCH:0:1}.$T"
MY_RELEASE="${GLUON_RELEASE:1}-$BRANCH-$T"

{

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

echo $RELEASE_TAG
echo $GLUON_RELEASE
echo $MY_RELEASE

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
		git checkout master
		#$GLUON_RELEASE
		git pull
	else
		cd $BASE_DIR/$BRANCH/gluon/site
		#/bin/rm -f ./README.md
		git checkout master
		git pull $SITE_REPO master
		#$GLUON_RELEASE
	fi	
fi
cd $BASE_DIR/$BRANCH/gluon

/bin/chown -R $USER:$USER $BASE_DIR/$BRANCH/
echo "> clean + update"
date
sleep 3

for TARGET in $TARGETS $TARGETSx86
do
	/usr/bin/sudo -u $USER make clean GLUON_TARGET=$TARGET
done

/usr/bin/sudo -u $USER make update

sleep 3

for TARGET in $TARGETS
do
	echo "> make $TARGET"
	date
	/usr/bin/sudo -u $USER make -j $THREADS GLUON_TARGET=$TARGET GLUON_BRANCH=$BRANCH GLUON_RELEASE=$MY_RELEASE $1
done

if [ -d "./output/images/sysupgrade" ]; then
	cd $BASE_DIR/$BRANCH/gluon/output/images/sysupgrade
	rm -f md5sum
	rm -f *.manifest
	md5sum * >> md5sums

	cd $BASE_DIR/$BRANCH/gluon/output/images/factory
	rm -f md5sum
	rm -f *.manifest
	md5sum * >> md5sums

	echo "> make manifest"
	date
	cd $BASE_DIR/$BRANCH/gluon

	/usr/bin/sudo -u $USER make manifest GLUON_BRANCH=$BRANCH GLUON_RELEASE=$MY_RELEASE
	/usr/bin/sudo -u $USER $BASE_DIR/$BRANCH/gluon/contrib/sign.sh $MAIN_DIR/secret $BASE_DIR/$BRANCH/gluon/output/images/sysupgrade/$BRANCH.manifest

	/bin/rm -rf $HTML_IMAGES_DIR

	/bin/mkdir -p $HTML_IMAGES_DIR
	/bin/cp -r $BASE_DIR/$BRANCH/gluon/output/images $HTML_IMAGES_DIR
	/bin/cp -r $BASE_DIR/$BRANCH/gluon/output/modules $HTML_IMAGES_DIR

	/bin/chown -R $USER:$USER $HTML_IMAGES_DIR

fi
} > >(tee -a /var/log/firmware-build/$MY_RELEASE.log) 2> >(tee -a /var/log/firmware-build/$MY_RELEASE.error.log | tee -a /var/log/firmware-build/$MY_RELEASE.log >&2)
