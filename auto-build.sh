#!/bin/sh
##

BASE_DIR = '/otp/gluon-update'

cd /otp/gluon-update/stable
git clone https://github.com/freifunk-gluon/gluon.git gluon -b v2016.1.6
cd ./gluon
mkdir 