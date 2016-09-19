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

if [ ! -d "$BASE_DIR/$BRANCH/gluon" ]; then
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

cd $BASE_DIR/$BRANCH/gluon
if [ "$NEW" == '0' ]; then
	##
	## pull GLUON release
	##
	git checkout $GLUON_RELEASE
	git pull $REPO $GLUON_RELEASE

	/bin/rm -rf $BASE_DIR/$BRANCH/gluon/site
	##
	## clone Site config
	##
	git clone $SITE_REPO site -b $GLUON_SITE_RELEASE

	cd $BASE_DIR/$BRANCH/gluon/site
	git checkout $GLUON_SITE_RELEASE
fi
cd $BASE_DIR/$BRANCH/gluon

/bin/chown -R $USER:$USER $BASE_DIR
echo "> clean + update"
date

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
	/usr/bin/sudo -u $USER make GLUON_TARGET=$TARGET GLUON_BRANCH=$BRANCH GLUON_RELEASE=$MY_RELEASE -j $THREADS $1
done

if [ -d "$BASE_DIR/$BRANCH/gluon/output/images" ]; then
	if [ -d "$BASE_DIR/$BRANCH/gluon/output/images/sysupgrade" ]; then
		cd $BASE_DIR/$BRANCH/gluon/output/images/sysupgrade
		rm -f md5sum
		rm -f *.manifest
		md5sum * >> md5sums
	fi

	if [ -d "$BASE_DIR/$BRANCH/gluon/output/images/factory" ]; then
		cd $BASE_DIR/$BRANCH/gluon/output/images/factory
		rm -f md5sum
		rm -f *.manifest
		md5sum * >> md5sums
	fi

	echo "> make manifest"
	date
	cd $BASE_DIR/$BRANCH/gluon

	/usr/bin/sudo -u $USER make manifest GLUON_BRANCH=$BRANCH GLUON_RELEASE=$MY_RELEASE

	cd $MAIN_DIR

	/usr/bin/sudo -u $USER $MAIN_DIR/sign.sh $MAIN_DIR/secret $BASE_DIR/$BRANCH/gluon/output/images/sysupgrade/$BRANCH.manifest

	cd $BASE_DIR/$BRANCH/gluon

	if [ -f "$BASE_DIR/$BRANCH/gluon/output/images/sysupgrade/$BRANCH.manifest" ]; then

		/bin/rm -rf $HTML_IMAGES_DIR

		/bin/mkdir -p $HTML_IMAGES_DIR
		/bin/cp -r $BASE_DIR/$BRANCH/gluon/output/images $HTML_IMAGES_DIR
		/bin/cp -r $BASE_DIR/$BRANCH/gluon/output/modules $HTML_IMAGES_DIR

		/bin/chown -R $USER:$USER $HTML_IMAGES_DIR
	fi

fi
} > >(tee -a /var/log/firmware-build/$MY_RELEASE.log) 2> >(tee -a /var/log/firmware-build/$MY_RELEASE.error.log | tee -a /var/log/firmware-build/$MY_RELEASE.log >&2)
