#!/bin/bash
# This script contains the default values used to setup the image

#################
# MySql Defaults
#################

MYSQL_ROOT_PASSWORD=root

###########################
# Don't change below this #
###########################

debconf-set-selections <<< "mysql-server-5.7 mysql-server/root_password password ${MYSQL_ROOT_PASSWORD}"
debconf-set-selections <<< "mysql-server-5.7 mysql-server/root_password_again password ${MYSQL_ROOT_PASSWORD}"