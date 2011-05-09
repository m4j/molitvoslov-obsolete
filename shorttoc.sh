#!/bin/sh

for i in *.tex; do
    if grep -q '^\\mypart' $i; then
        #echo "$i -- yes";
        fname=`expr $i : "\(.*\)\."`;
        #echo $fname;
        sed -n "s/^\\\mypart{\(.*\)}\\\label.*$/\\\Large \1\\\hfill\\\ref{$fname}\n\n\\\medskip\n/p" $i
    fi
done
