#!/bin/bash

##
## Main config
##

BRANCH="stable"
GLUON_RELEASE="v2016.1.6"
SITE="ksia"
USER="u1227"

TARGETS="ar71xx-generic ar71xx-nand mpc85xx-generic"
#TARGETS="ar71xx-generic ar71xx-nand mpc85xx-generic x86-xen_domu x86-kvm_guest"
TARGETSx86="x86-generic x86-64"
THREADS="4"

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

