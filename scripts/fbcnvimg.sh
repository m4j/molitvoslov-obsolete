#!/bin/bash
#
#       fbcnvimg.sh
#
#       Given a name as an argument, this script finds image file and outputs 
#       <binary> tag with base-64 contents according to Fiction Book v 2.0 spec
#       to stdout.
#       
#       Copyright 2012 Max Agapov <m4j@swissmail.org>
#       
#       This program is free software; you can redistribute it and/or modify
#       it under the terms of the GNU General Public License as published by
#       the Free Software Foundation; either version 2 of the License, or
#       (at your option) any later version.
#       
#       This program is distributed in the hope that it will be useful,
#       but WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#       GNU General Public License for more details.
#       
#       You should have received a copy of the GNU General Public License
#       along with this program; if not, write to the Free Software
#       Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#       MA 02110-1301, USA.

print_item() {
    printf '\n<binary id="%s" content-type="%s">\n' "$1" "$2"
    base64 "$3"
    printf '</binary>'
}

IMG_DIR=$1
shift

#echo $@
#exit

for NAME in $@; do

  # output images
  for file in `find $IMG_DIR -type f -name "$NAME.png"`; do
    print_item "$NAME" "image/png" "$file"
  done

  # match both 'jpg' and 'jpeg'
  for file in `find $IMG_DIR -type f -name "$NAME.jp*g"`; do
    print_item "$NAME" "image/jpeg" "$file"
  done

done

