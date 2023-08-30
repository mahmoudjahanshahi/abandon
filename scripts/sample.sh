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

#defined packages
LC_ALL=C LANG=C join -t\; -1 1 -2 2 -a1 \
    <(zcat data/p2P2p.s | cut -d\; -f2 | ~/lookup/lsort 10G -u) \
    <(zcat /da5_data/play/releases/Def2PFullU.s | ~/lookup/lsort 50G -t\; -k2) |
~/lookup/lsort 50G -t\; -u |   
gzip >data/P2Def.s; # wc -l 163
for i in {0..127}; do
    LC_ALL=C LANG=C join -t\; -2 2 \
        <(zcat data/p2P2p.s | cut -d\; -f2 | ~/lookup/lsort 10G -u) \
        <(zcat /da?_data/basemaps/gz/c2PtAbflDefFullU"$i".s | ~/lookup/lsort 50G -t\; -k2,2);
done |
~/lookup/lsort 50G -t\; -u |
gzip >data/P2ctAbflDef.s;

#dependant projects
LC_ALL=C LANG=C join -t\; \
    <(zcat data/P2Def.s | cut -d\; -f2 | ~/lookup/lsort 10G -u) \
    <(zcat /da5_data/play/releases/Pkg2PFullU.s | ~/lookup/lsort 50G -t\;) |
~/lookup/lsort 50G -t\; -u |   
gzip >data/Pkg2P.s;
