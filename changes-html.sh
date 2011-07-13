#/!bin/sh

sed -e 's;\\section\*{\(.*\)};<h2>\1</h2>;' $1
