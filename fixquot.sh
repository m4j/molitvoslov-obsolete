#!/bin/bash

#git checkout _*tex
sed -i 's/"---/\&mdash;/g' _*tex
sed -i 's/&quot;/"/g' _*tex
sed -i 's/"\([[:alnum:]\.,:;(){}&?[:space:]]\+\)"/«\1»/g' _*tex
grep -Hn '"' _*tex
sed -i 's/\&mdash;/"---/g' _*tex
sed -i 's/–/"---/g' _*tex
sed -i 's/—/"---/g' _*tex
sed -i 's/т\.е\./т.~е./g' _*tex
sed -i 's/т\.д\./т.~д./g' _*tex
sed -i 's/\.\.\./\ldots/g' _*tex

#fix some invisible unicode characters
sed -i 's/ //g' _*tex
sed -i 's/­//g' _*tex
