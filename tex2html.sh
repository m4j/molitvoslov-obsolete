#/!bin/sh

sed \
    -e 's;\\section\*{\(.*\)};<h3>\1</h3>;' \
    -e 's;^\([[:alpha:]].*\)$;<p>\1</p>;' \
    -e 's;\\begin{itemize};<ul>;' \
    -e 's;\\end{itemize};</ul>;' \
    -e 's;\\item \(.*\);<li>\1</li>;' \
    -e '/^\\.*$/d' \
    -e 's/%.*$//g' \
    -e '/^$/d' \
    $1
