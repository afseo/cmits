#!/bin/sh

DESTDIR=/net/admin/BACKUPS/`hostname -s`/LOGS

# $TMPDIR must have enough space to hold all the repositories roughly twice,
# and be writable by whoever is running this script.
TMPDIR=/tmp
NAME=system_logs-`date +%Y-%m-%d--%H-%M-%S`




set -e

TMP=`mktemp -dt $ME.XXXXXXXXXXX`
# Exclude lastlog: it is very large, though sparse, so it takes a long time to
# tar. Its data is in other log files as well, so we're not losing any data.
# files
tar -c -z --one-file-system -C /var --exclude log/lastlog -f $TMP/$NAME.tar.gz log
mv $TMP/$NAME.tar.gz $DESTDIR
rmdir $TMP

/usr/sbin/logrotate -f /etc/logrotate.conf
