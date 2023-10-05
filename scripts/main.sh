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

# joining with clean Def
for batch in {ab,up,vu}; do
    LC_ALL=C LANG=C join -t\; \
        <(zcat "data/tmp/Def.$batch.$ver" | ~/lookup/lsort 50G -u) \
        <(zcat "data/tmp/Pkg2P.$batch.$ver" | ~/lookup/lsort 50G -t\; -u -k1,1) | 
    gzip >"data/tmp/Pkg2P.$batch.$ver.c";
done;

# target def
for batch in {ab,up,vu}; do
    for i in {0..127}; do
        zcat "data/tmp/split/Pkg2P.$batch.$ver.$i.t";
    done |
    ~/lookup/lsort 50G -u -t\; |
    gzip >"data/tmp/Pkg2P.$batch.$ver.t";
done;

#joining with P2Def
for g in {c,t}; do
    for batch in {ab,up,vu}; do
        LC_ALL=C LANG=C join -t\; -1 2 -2 1 -o 1.1 1.2 2.2 \
            <(zcat "data/tmp/P2Def.$batch.$ver" | sed 's|;JS:|;|' | ~/lookup/lsort 50G -t\; -u -k2,2) \
            <(zcat "data/tmp/Pkg2P.$batch.$ver.$g" | ~/lookup/lsort 50G -t\; -u -k1,1) |
        ~/lookup/lsort 50G -t\; -u |
        gzip >"data/main/P2Pkg2P.$batch.$ver.$g";
    done;
done;
for g in {c,t}; do
    for batch in {ab,up,vu}; do
        n=$(zcat "data/main/P2Pkg2P.$batch.$ver.$g" | wc -l);
        echo "# $batch $g wc -l: $n";
    done;
done;
