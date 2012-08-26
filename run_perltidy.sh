#!/bin/bash

cat <<EOF
 This will overwrite your files and remove the perltidy backups.

 You better have commited your changes. If you need to clean up your code,
 use git commit --amend.

EOF

echo -n "Continue? [yN] "

read confirmation

if [ $confirmation == 'y' ]
then
	find lib/ -name '*.pm' -print -exec perltidy --pro=.perltidyrc {} \;

	find lib/ -name '*.pm.perltidy' -delete
else
	echo Aborted.
fi
