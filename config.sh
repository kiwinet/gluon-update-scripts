#!/bin/bash

##
## Main config
##

BRANCH="stable"
GLUON_RELEASE="v2016.1.6"
SITE="ksia"
USER="u1227"

##
## PubKey
##

SECRETKEY=`/bin/cat secret`

##
## REPO
##

REPO="https://github.com/freifunk-gluon/gluon.git"
SITE_REPO="https://github.com/kiwinet/site-$SITE.git"

##
## DIR config
##

BASE_DIR="/opt/gluon-update"
HTML_IMAGES_DIR="/home/u1227/web/siauliai.kiwinet.eu/public_html/firmware/$BRANCH/"
HTML_MODULES_DIR="/home/u1227/web/siauliai.kiwinet.eu/public_html/firmware/$BRANCH/modules"

