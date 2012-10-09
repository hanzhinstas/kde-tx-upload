#!/bin/bash
# Generate list of project names for transifex
# Below are some configuration parameters
#
# set KDE_VERSION variable to specify version we are working with
KDE_VERSION=4.9.2
# set TX_UPLOAD_DIR relative to the current working directory of this script to store content suitable for uploading to TX
TX_UPLOAD_DIR="tx_upload"

#function unpack_translations {
#for file in `ls -d ./*.tar.xz`; do
#	tar -xf $file -C tmp;
#done
#}

function pretransfer_translation {
find ./tmp/kde-l10n-$kde_locale-$KDE_VERSION/messages/ -iname *.po > ./tmp/kde-l10n-$kde_locale-$KDE_VERSION/pofile_list
for file in `cat ./tmp/kde-l10n-$kde_locale-$KDE_VERSION/pofile_list`; do
	target_resource=$(echo $file | sed -e "s/^.*messages\///g" -e 's/\//\./g' -e 's/\.po//g');
	mkdir -p ./$TX_UPLOAD_DIR/$target_resource;
	cp $file ./$TX_UPLOAD_DIR/$target_resource/$kde_locale.po;
done
}

mkdir -p $TX_UPLOAD_DIR
mkdir tmp
touch $TX_UPLOAD_DIR/locales
for kde_locale in `cat ./subdirs` ; do
	pretransfer_translation;
done

