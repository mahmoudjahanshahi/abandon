#!/usr/bin/bash

ver=U;

# cleansing Def
for batch in {ab,up,vu}; do
    zcat "data/tmp/P2Def.$batch.$ver" |
    cut -d\; -f2 | 
    cut -d: -f2 | 
    ~/lookup/lsort 10G -u |
    awk '{if (length>1) print}' |
    grep -v "^<%=.*%>$" |
    grep -v "^<%.*%>$" |
    grep -v "^{.*}" |
    gzip >"data/tmp/Def.$batch.$ver";
done;

# splitting large files
for batch in {ab,up,vu}; do
    zcat data/Pkg2cPtAbfl.$batch.$ver | 
    cut -d\; -f1,3 | 
    uniq |
    split - -d -l1000000000 --filter='gzip > $FILE.gz' data/split/Pkg2P.$batch.$ver. ;
done;
