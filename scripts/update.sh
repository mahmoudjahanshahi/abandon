#!/usr/bin/bash

ver=U;
batch=up;

# p2P2p 
start=$(date +%s);
tail -n +2 <data/main/dependencyUpdateSampleComplete.csv |
cut -d\, -f1 |
sed 's|/|_|1;s|/.*||' |
~/lookup/lsort 10G -u | # 5,717
~/lookup/getValues -f p2P |
~/lookup/lsort 10G -t\; -k2,2 -u |
gzip >data/tmp/p2P.${batch}.${ver};
zcat data/tmp/p2P.${batch}.${ver} |
cut -d\; -f2 |
~/lookup/getValues -f P2p |
~/lookup/lsort 10G -t\; -k1,1 |
gzip >data/tmp/P2p.${batch}.${ver};
LC_ALL=C LANG=C join -t\; -a1 -1 2 -2 1 -o 1.1 1.2 2.2 \
    <(zcat data/tmp/p2P.${batch}.${ver}) \
    <(zcat data/tmp/P2p.${batch}.${ver}) |
~/lookup/lsort 10G -t\; -u |
gzip >data/main/p2P2p.${batch}.${ver}; # 1,485,871 # uniq P 5,360 
end=$(date +%s);
echo "Elapsed time: $((end - start)) seconds"; # 27 seconds

# defined packages
## only if p==P
start=$(date +%s);
zcat data/main/p2P2p.${batch}.${ver} | 
awk -F\; '{IGNORECASE=1;if ($1==$2) {print}}' |
cut -d\; -f2 | 
~/lookup/lsort 10G -u |
gzip >data/tmp/P.${batch}.${ver}; # 4,140
for i in {0..127}; do
    LC_ALL=C LANG=C join -t\; -2 2 \
        <(zcat data/tmp/P.${batch}.${ver}) \
        <(zcat /da?_data/basemaps/gz/c2PtAbflDefFullU"$i".s | ~/lookup/lsort 50G -t\; -k2,2);
done |
~/lookup/lsort 50G -t\; -u |
gzip >data/main/P2ctAbflDef.${batch}.${ver}; # 2,104,540
end=$(date +%s);
echo "Elapsed time: $((end - start)) seconds"; # 2,299 seconds

# dependent projects
## only JS
zcat data/main/P2ctAbflDef.${batch}.${ver} |
awk -F\; '{print $1";"$7":"$8}' |
~/lookup/lsort 50G -t\; -u |   
grep ";JS:" |
gzip >data/tmp/P2Def.${batch}.${ver}; # 38,049
## Pkg2cPtAbfl
start=$(date +%s);
for i in {0..127}; do
    LC_ALL=C LANG=C join -t\; -2 8 \
        <(zcat data/tmp/P2Def.${batch}.${ver} | cut -d\; -f2 | cut -d: -f2 | ~/lookup/lsort 10G -u) \
        <(zcat /da?_data/basemaps/gz/c2PtAbflPkgFullU"$i".s | 
            awk -F\; '{OFS=";";if ($7=="JS") {for (i=8;i<=NF;++i)print $1,$2,$3,$4,$5,$6,$7,$i}}' |
            ~/lookup/lsort 50G -t\; -k8);
done |
gzip >data/main/Pkg2cPtAbfl.${batch}.${ver}; # wc -l 24,972,532,376
end=$(date +%s);
echo "Elapsed time: $((end - start)) seconds"; # 496,590 seconds, 5.75 days
## Pkg2P
start=$(date +%s);
zcat data/main/Pkg2cPtAbfl.${batch}.${ver} | 
cut -d\; -f1,3 | 
~/lookup/lsort 60G -t\; -u |
gzip >data/main/Pkg2P.${batch}.${ver}; 
end=$(date +%s);
echo "Elapsed time: $((end - start)) seconds";

# Target package list from original files
tail -n +2 <data/main/dependencyUpdateSampleComplete.csv |
cut -d\, -f2 |
~/lookup/lsort 10G -u |
gzip >"data/tmp/tDef.$batch.$ver"; # wc -l 6000
start=$(date +%s);
for i in {0..127}; do
    LC_ALL=C LANG=C join -t\; -2 2 \
        <(zcat data/tmp/tDef.${batch}.${ver} | ~/lookup/lsort 10G -t\;) \
        <(zcat /da?_data/basemaps/gz/c2PtAbflPkgFullU"$i".s |
            awk -F\; '{OFS=";";if ($7=="JS") {for (i=8;i<=NF;++i)print $2,$i}}' |
            ~/lookup/lsort 100G -t\; -k2) |
        ~/lookup/lsort 20G -u -t\; |
        gzip >"data/tmp/split/Pkg2P.$batch.$ver.$i.t";
done;
end=$(date +%s);
echo "Elapsed time: $((end - start)) seconds"; # 107324 seconds

# Def
start=$(date +%s);
for i in {0..127}; do
    LC_ALL=C LANG=C join -t\; -2 2 \
        <(zcat data/tmp/Def.${batch}.${ver} | ~/lookup/lsort 10G -t\;) \
        <(zcat /da?_data/basemaps/gz/c2PtAbflPkgFullU"$i".s |
            awk -F\; '{OFS=";";if ($7=="JS") {for (i=8;i<=NF;++i)print $2,$i}}' |
            ~/lookup/lsort 100G -t\; -k2) |
        ~/lookup/lsort 20G -u -t\; |
        gzip >"data/tmp/split/Pkg2P.$batch.$ver.$i.c";
done;
end=$(date +%s);
echo "Elapsed time: $((end - start)) seconds"; # 153855 seconds
