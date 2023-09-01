#!/usr/bin/bash

# p2P2p
tail -n +2 <data/dependencyAbandonmentSample.csv |
cut -d\, -f1 |
sed 's|/|_|1' |
~/lookup/getValues -f p2P |
sort -t\; -k2 |
gzip >data/tmp/p2P.s;
zcat data/tmp/p2P.s |
cut -d\; -f2 |
~/lookup/getValues -f P2p |
sort -t\; |
gzip >data/tmp/P2p.s;
join -t\; -a1 -1 2 -2 1 -o 1.1 1.2 2.2\
    <(zcat data/tmp/p2P.s) \
    <(zcat data/tmp/P2p.s) |
~/lookup/lsort 10G -t\; -u |
gzip >data/p2P2p.s; # wc -l 6881

# defined packages
## based on Def2PFullU
LC_ALL=C LANG=C join -t\; -1 1 -2 2 -a1 \
    <(zcat data/p2P2p.s | cut -d\; -f2 | ~/lookup/lsort 10G -u) \
    <(zcat /da5_data/play/releases/Def2PFullU.s | ~/lookup/lsort 50G -t\; -k2) |
~/lookup/lsort 50G -t\; -u |   
gzip >data/P2Def.s; # wc -l 163
## based on c2PtAbflDefFullU
for i in {0..127}; do
    LC_ALL=C LANG=C join -t\; -2 2 \
        <(zcat data/p2P2p.s | cut -d\; -f2 | ~/lookup/lsort 10G -u) \
        <(zcat /da?_data/basemaps/gz/c2PtAbflDefFullU"$i".s | ~/lookup/lsort 50G -t\; -k2,2);
done |
~/lookup/lsort 50G -t\; -u |
gzip >data/P2ctAbflDef.s; # wc -l 6170
zcat data/P2ctAbflDef.s |
awk -F\; '{print $1";"$7":"$8}' |
~/lookup/lsort 50G -t\; -u |   
gzip >data/P2Def2.s; # wc -l 188

# dependant projects
## P2Def
LC_ALL=C LANG=C join -t\; \
    <(zcat data/P2Def.s | cut -d\; -f2 | ~/lookup/lsort 10G -u) \
    <(zcat /da5_data/play/releases/Pkg2PFullU.s | ~/lookup/lsort 50G -t\;) |
~/lookup/lsort 50G -t\; -u |   
gzip >data/Pkg2P.s; # wc -l 191132 # 187720 uniq P #join: /proc/self/fd/15:11: is not sorted: C:";bobrippling_ucc-c-compiler
for i in {0..127}; do
    LC_ALL=C LANG=C join -t\; -2 2 \
        <(zcat data/Pkg2P.s | cut -d\; -f2 | ~/lookup/lsort 10G -u) \
        <(zcat /da?_data/basemaps/gz/c2PtAbflPkgFullU"$i".s | ~/lookup/lsort 50G -t\; -k2,2);
done |
~/lookup/lsort 50G -t\; -u |
gzip >data/P2ctAbflPkg.s; # wc -l 95,641,767
zcat data/P2ctAbflPkg.s |
awk -F\; '{OFS=";";for (i=8;i<=NF;++i)print $1,$2,$3,$4,$5,$6,$7,$i}' |
~/lookup/splitSecCh.perl data/tmp/P2ctAbflPkg. 127 ;
## P2Def2
### Pkg2P
LC_ALL=C LANG=C join -t\; \
    <(zcat data/P2Def2.s | cut -d\; -f2 | cut -d: -f2 |  ~/lookup/lsort 10G -u) \
    <(zcat /da5_data/play/releases/Pkg2PFullU.s | awk -F: '{if ($1=="JS") print $2}'| ~/lookup/lsort 50G -t\; -u) |
~/lookup/lsort 50G -t\; -u |   
gzip >data/Pkg2P2.s;
### c2PtAbflPkg
for i in {0..127}; do
    LC_ALL=C LANG=C join -t\; -2 8 \
        <(zcat data/P2Def2.s | cut -d\; -f2 | cut -d: -f2 | ~/lookup/lsort 10G -u) \
        <(zcat /da?_data/basemaps/gz/c2PtAbflPkgFullU"$i".s | 
            awk -F\; '{OFS=";";if ($7=="JS") {for (i=8;i<=NF;++i)print $1,$2,$3,$4,$5,$6,$7,$i}}' |
            ~/lookup/lsort 50G -t\; -k8);
done |
gzip >data/Pkg2cPtAbfl.s;
