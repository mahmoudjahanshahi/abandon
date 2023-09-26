#!/usr/bin/bash

ver=U;
batch=up;

# p2P2p 
start=$(date +%s);
tail -n +2 <data/main/dependencyUpdateSampleComplete.csv |
cut -d\, -f1 |
sed 's|/|_|1;s|/.*||' |
~/lookup/lsort 10G -u |
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
gzip >data/main/P2ctAbflDef.${batch}.${ver}; 
end=$(date +%s);
echo "Elapsed time: $((end - start)) seconds";
