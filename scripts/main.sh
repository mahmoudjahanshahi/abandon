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
## joining with P2Def
for batch in {ab,up,vu}; do
    LC_ALL=C LANG=C join -t\; -2 2 -o 2.1 1.1 \
        <(zcat "data/tmp/Def.$batch.$ver" | ~/lookup/lsort 10G -t\; -u) \
        <(zcat "data/tmp/P2Def.$batch.$ver" | sed 's|;JS:|;|' | ~/lookup/lsort 10G -t\; -k2,2) |
    ~/lookup/lsort 10G -t\; -u |
    gzip >"data/main/P2Def.$batch.$ver";
done;

# splitting large files
for batch in {ab,up,vu}; do
    zcat data/Pkg2cPtAbfl.$batch.$ver | 
    cut -d\; -f1,3 | 
    uniq |
    split - -d -l1000000000 --filter='gzip > $FILE.gz' data/split/Pkg2P.$batch.$ver. ;
done;

# combining
for g in {c,t}; do
    for batch in {ab,up,vu}; do
        for i in {0..127}; do
            zcat "data/tmp/split/Pkg2P.$batch.$ver.$i.$g";
        done |
        ~/lookup/lsort 50G -u -t\; |
        gzip >"data/tmp/Pkg2P.$batch.$ver.$g";
    done;
done;

for g in {c,t}; do
    for batch in {ab,up,vu}; do
        n=$(zcat "data/tmp/Pkg2P.$batch.$ver.$g" | wc -l);
        echo "# $batch $g wc -l: $n";
    done;
done;
# ab c wc -l: 2867388596 , 29G
# up c wc -l: 2745894677 , 28G
# vu c wc -l: 1443875991 , 15G
# ab t wc -l: 139759093 , 1.4G
# up t wc -l: 353838181 , 3.6G
# vu t wc -l: 199946370 , 2G
for g in {t,c}; do
    for batch in {ab,up,vu}; do
        n=$(zcat "data/tmp/Pkg2P.$batch.$ver.$g" | cut -d\; -f2 | ~/lookup/lsort 50G -t\; -u | wc -l);
        echo "# $batch $g wc -l: $n";
    done;
done;
# ab t wc -l: 5021721
# up t wc -l: 6203454
# vu t wc -l: 6174365
# ab c wc -l: 8105686
# up c wc -l: 7400931
# vu c wc -l: 7236131

#joining with P2Def
for batch in {ab,up,vu}; do
    LC_ALL=C LANG=C join -t\; -1 2 -2 1 -o 1.1 1.2 2.2 \
        <(zcat "data/tmp/P2Def.$batch.$ver" | sed 's|;JS:|;|' | ~/lookup/lsort 50G -t\; -u | ~/lookup/lsort 50G -t\; -k2,2) \
        <(zcat "data/tmp/Pkg2P.$batch.$ver.c" | ~/lookup/lsort 100G -t\; -u) |
    gzip >"data/main/P2Pkg2P.$batch.$ver.c";
done;

# uniq dP
for batch in {ab,up,vu}; do
    zcat "data/main/Pkg2P.$batch.$ver.t" | 
    cut -d\; -f2 | 
    ~/lookup/lsort 300G -t\; -u | 
    gzip >"data/main/dP.$batch.$ver.t";
done;
## replacing P with URL
for batch in {ab,up,vu}; do
    # finding other domains
    zcat "data/main/dP.$batch.$ver.t" | 
    sed 's|_|/|1' |
    cut -d/ -f1 | 
    grep "\." | 
    sort -u |
    sed 's|^|^|;s|$|/|' >"data/tmp/dPdomains.$batch.$ver.t";
    # creating github urls
    zcat "data/main/dP.$batch.$ver.t" | 
    sed 's|_|/|1' |
    grep -v -f "data/tmp/dPdomains.$batch.$ver.t" |
    sed 's|^|github.com/|' |
    ~/lookup/lsort 30G -u |
    gzip >"data/main/dPgithub.$batch.$ver.t";
    # creating other urls
    zcat "data/main/dP.$batch.$ver.t" | 
    sed 's|_|/|1' |
    grep -f "data/tmp/dPdomains.$batch.$ver.t" |
    ~/lookup/lsort 30G -u |
    gzip >"data/main/dPother.$batch.$ver.t";
done;

# no dependency claim sample
tail -n +2 <data/main/dependenciesNotInPackageJson.csv | 
awk -F\" '{OFS=";";print $2,$4}' | 
head >data/tmp/noDepsample.Pkg2P;
for i in {0..127}; do
    zcat /da?_data/basemaps/gz/c2PtAbflPkgFullU"$i".s | 
    grep -f <(cut -d\; -f2 <data/tmp/noDepsample.Pkg2P | sed 's|^|;|;s|$|;|');
done |
gzip >data/tmp/c2PtAbflPkgFullU.noDepSample;
while read -r l; do
    p=$(echo $l | cut -d\; -f2);
    d=$(echo $l | cut -d\; -f1);
    zcat data/tmp/c2PtAbflPkgFullU.noDepSample | 
    grep ";$p;" | 
    grep ";$d" |
    cut -d\; -f1,2,5,6 | 
    awk -F\; -v d="$d" '{OFS=";";print d,$2,$1,$4,$3}';
done <data/tmp/noDepsample.Pkg2P |
sort -u |
gzip >data/main/PkgP2cfb.noDepSample;
