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
