#!/bin/bash

get_latex_field(){
    sed -n "s/\\\\$1{\(.*\)}/\1/p" "$2"
}

TARGET=$1
HTML_DIR=$2
XSLT=$3

if [ -z "$TITLE" ]; then
    TITLE=`get_latex_field title $TARGET.tex`
fi
if [ -z "$AUTHOR" ]; then
    AUTHOR=`get_latex_field author $TARGET.tex`
fi
if [ -z "$DATE" ]; then
    DATE=`get_latex_field date $TARGET.tex`
fi

# transform all matching html files in the directory
for file in ${HTML_DIR}/${TARGET}*.html; do
    printf 'Transforming %s...' "$file"
    mv "$file" "$file~" && xsltproc -o "$file" "$XSLT" "$file~"
    rc=$?
    if [ $rc -ne 0 ]; then
        # if something went wrong, restore previous order
        printf 'failed with error code %s\n' $rc
        mv "$file~" "$file"
        exit $rc
    fi
    rm -f "$file~"
    printf 'done\n'
done
