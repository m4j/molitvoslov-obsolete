#!/bin/bash

get_latex_field(){
    sed -n "s/\\\\$1{\(.*\)}/\1/p" $2
}

print_item() {
    [ -f "$2" ] && printf '    <item id="%s" href="%s" media-type="%s" />\n' $1 $2 $3
}

TARGET=$1
HTML_DIR=$2

if [ -z "$TITLE" ]; then
    TITLE=`get_latex_field title $TARGET.tex`
fi
if [ -z "$AUTHOR" ]; then
    AUTHOR=`get_latex_field author $TARGET.tex`
fi
if [ -z "$DATE" ]; then
    DATE=`get_latex_field date $TARGET.tex`
fi

cat <<EOF
<?xml version="1.0" encoding="utf-8"?>
<package xmlns="http://www.idpf.org/2007/opf" unique-identifier="bookid" version="2.0">
  <metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
      <dc:title>$TITLE</dc:title>
      <dc:creator>$AUTHOR</dc:creator>
      <dc:publisher>$PUBLISHER</dc:publisher>
      <dc:format></dc:format>
      <dc:date>$DATE</dc:date>
      <dc:subject></dc:subject>
      <dc:description></dc:description>
      <dc:rights>NONE</dc:rights>
      <dc:identifier id="bookid">$BOOK_ID</dc:identifier>
      <dc:language>$BOOK_LANG</dc:language>
  </metadata>
  <manifest>
    <item id="pt" href="page-template.xpgt" media-type="application/vnd.adobe.page-template+xml"/>
    <item id="style" href="$TARGET.css" media-type="text/css" />
    <item id="cover" href="cover.html" media-type="application/xhtml+xml" />
    <item id="toc" href="$TARGET.html" media-type="application/xhtml+xml" />
    <item id="ncx" href="toc.ncx" media-type="application/x-dtbncx+xml" />
EOF

cd $HTML_DIR

# output fonts
for file in fonts/*ttf; do
    print_item `basename $file` $file "application/x-font-ttf"
done

# output chapters
for file in ${TARGET}ch?\.html; do
    print_item $file $file "application/xhtml+xml"
done
for file in ${TARGET}ch??\.html; do
    print_item $file $file "application/xhtml+xml"
done

# output images
for file in *.png; do
    print_item $file $file "image/png"
done
for file in *.jpg; do
    print_item $file $file "image/jpeg"
done


cat <<EOF
  </manifest>
  <spine toc="ncx">
    <itemref idref="cover" linear="no"/>
    <itemref idref="toc" />
EOF

# output itemrefs
for file in ${TARGET}ch?\.html; do
    printf '    <itemref idref="%s" />\n' $file
done
for file in ${TARGET}ch??\.html; do
    printf '    <itemref idref="%s" />\n' $file
done

cat <<EOF
  </spine>
  <guide>
    <reference type="toc" title="Оглавление" href="$TARGET.html" />
    <reference type="other.ms-coverimage-standard" title="Cover" href="cover.jpg" />
    <reference type="other.ms-thumbimage-standard" title="ThumbImageStandard" href="cover.jpg" />
    <reference type="other.ms-thumbimage" title="PPCThumbnailImage" href="thumb.jpg" />
    <!--
    <reference type="copyright" title="Copyright" href="bano_9781411432963_oeb_cop_r1.html" />
    <reference type="beginreading" title="Begin reading" href="bano_9781411432963_oeb_p01_r1.html" />
    -->
  </guide>
</package>
EOF
