#!/bin/bash
#
# Copyright (C) 2000-2015 Kern Sibbald
# License: BSD 2-Clause; see file LICENSE-FOSS
#
# This script deletes a catalog dump
#

if [ $# == 0 ]    # check if any argument exist
  then            # show help
    echo "No arguments"
    echo
    echo "Usage:"
    echo "       delete_catalog_backup.sh %dbname%"
    echo
    exit 1
  else
    db_name=$1
fi

#db_name=XXX_DBNAME_XXX

rm -f /var/lib/bacula/${db_name}.sql

#
# We recommend that you email a copy of the bsr file that was
#  made for the Job that runs this script to yourself.
#  You just need to put the bsr file in /opt/bacula/bsr/catalog.bsr
#  or adjust the script below.  Please replace all %xxx% with what
#  is appropriate at your site.
#
#/opt/bacula/bin/bsmtp -h %smtp-server% -s "catalog.bsr" \
#   %your-name@company.org% </opt/bacula/bsr/catalog.bsr

