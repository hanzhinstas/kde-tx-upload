#!/bin/bash
# Generate list of project names for transifex
# Below are some configuration parameters
#
# set KDE_VERSION variable to specify version we are working with
KDE_VERSION=4.9.2
# L10N_SVN_DIR should point to l10n-kde dir location in your kde svn checkout.
L10N_SVN_DIR="/home/hanzhinstas/workspace/rosa/l10n-kde4"
SYNC_DIR="/home/hanzhinstas/workspace/rosa/tx-l10n-kde"

function pretransfer_translation {
echo "Executing pretransfer step for locale $KDE_LOCALE"
if [ "$KDE_LOCALE" == "ru" ]; then
	EXPORT_LOCALE="ru_kde";
else
	EXPORT_LOCALE=$KDE_LOCALE;
fi
echo $EXPORT_LOCALE
for file in `find $L10N_SVN_DIR/$KDE_LOCALE/messages/ -iname *.po`; do
	target_resource=$(echo $file | sed -e "s/^.*messages\///g" -e 's/\//\./g' -e 's/\.po//g');
	target_project_name=$(echo $file | sed -e "s/^.*messages\///g" -e 's/\//\./g' -e 's/\..*$//g');
	target_resource_name=$(echo $file | sed -e "s/^.*messages\///g" -e 's/\.po/\.pot/g');
	if [ ! -x $SYNC_DIR/$target_resource ]; then
		mkdir -p $SYNC_DIR/$target_resource;
		cp $L10N_SVN_DIR/templates/messages/$target_resource_name $SYNC_DIR/$target_resource/en.pot;
	fi
	cp $file $SYNC_DIR/$target_resource/$EXPORT_LOCALE.po;
done
}

function transfer_translation {
echo "Executing transfer step for $KDE_RESOURCE"
cd $SYNC_DIR/$KDE_RESOURCE
tx set --auto-local -r $KDE_RESOURCE '<lang>.po' --source-file en.pot -s en --execute
echo "type = PO" >> $SYNC_DIR/.tx/config
tx push -s -t
echo "Transfer step for resource $KDE_RESOURCE complete"
}

if [ -n "$SYNC_DIR" ]; then
	echo "Using $SYNC_DIR for syncronization."
	mkdir -p $SYNC_DIR
else
	echo "No SYNC_DIR variable set. Using $L10N_SVN_DIR for transfer."
	SYNC_DIR=$L10N_SVN_DIR
fi
echo "Entering pretransfer step..."
for KDE_LOCALE in `cat $L10N_SVN_DIR/subdirs` ; do
	pretransfer_translation;
done
echo "Pretransfer step complete."
echo "Entering transfer step"
for KDE_RESOURCE in `ls -d $SYNC_DIR` ; do
	transfer_translation;
done
echo "Transfer step complete"

