#!/bin/bash

##
## Config
##
MAIN_DIR="/opt/gluon-update-scripts"

##
## Body
##
{
NEW="0"
source $MAIN_DIR/config.sh
T="$(date +"%Y%m%d_%H:%M:%S")"
RELEASE_TAG="$GLUON_RELEASE.${BRANCH:0:1}.$T"
MY_RELEASE="${GLUON_RELEASE:1}-$BRANCH-$T"


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
exit 1
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
		#/bin/rm -f ./README.md
		git checkout $GLUON_RELEASE
		git pull $SITE_REPO $GLUON_RELEASE
	fi	
fi
cd $BASE_DIR/$BRANCH/gluon

echo ""
sleep 3

for TARGET in $TARGETS $TARGETSx86
do
	make clean GLUON_TARGET=$TARGET
done

make update

echo ""
sleep 3

for TARGET in $TARGETS
do
	make -j $THREADS GLUON_TARGET=$TARGET GLUON_BRANCH=$BRANCH GLUON_RELEASE=$MY_RELEASE
done

cd ./output/images/sysupgrade
rm -f md5sum
rm -f *.manifest
md5sum * >> md5sums

cd ../factory
rm -f md5sum
rm -f *.manifest
md5sum * >> md5sums

cd $BASE_DIR/$BRANCH/gluon

make manifest GLUON_BRANCH=$BRANCH
./contrib/sign.sh $SECRETKEY ./output/images/sysupgrade/$BRANCH.manifest

/bin/rm -rf $HTML_IMAGES_DIR

/bin/mkdir -p $HTML_IMAGES_DIR
/bin/cp -r ./output/images $HTML_IMAGES_DIR
/bin/cp -r ./output/modules $HTML_IMAGES_DIR

/bin/chown -R $USER:$USER $HTML_IMAGES_DIR

} > >(tee -a /var/log/firmware-build/$MY_RELEASE.log) 2> >(tee -a /var/log/firmware-build/$MY_RELEASE.error.log | tee -a /var/log/firmware-build/$MY_RELEASE.log >&2)
