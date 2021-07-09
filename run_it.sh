TMP=( ptrVet_aux.tmp rowVet_aux.tmp matPtr_aux.tmp matRow_aux.tmp )
TMP2=( ptrVet_aux2.tmp rowVet_aux2.tmp matPtr_aux2.tmp matRow_aux2.tmp )

echo "multMatPtrVet" > ptrVet_aux.tmp
echo "multMatRowVet" > rowVet_aux.tmp
echo "multMatMatPtr" > matPtr_aux.tmp
echo "multMatMatRow" > matRow_aux.tmp

for file in ${TMP2[*]};
do
    echo "N:Time elapsed [s]" > $file
done

for file in ${TMP[*]};
do
    echo >> $file
    echo "N:Memory bandwidth [MBytes/s]" >> $file
done

PROGRAM=./matmult
for N in 64 100 128;
do
    likwid-perfctr -C 3 -g L3 -m "$PROGRAM -n $N" > aux.tmp
    RESULT=$(cat aux.tmp | grep "L3 bandwidth" | cut -d'|' -f3)
    RESULT=$(echo ${RESULT//$'\n'/})

    let counter=0
    for r in $RESULT;
    do
        echo -n "$N:" >> ${TMP[$counter]}
        echo $r >> ${TMP[$counter]}
        let counter++
    done

    RESULT=$(cat aux.tmp | grep "RDTSC Runtime" | cut -d'|' -f3)
    RESULT=$(echo ${RESULT//$'\n'/})

    let counter=0
    for r in $RESULT;
    do
        echo -n "$N:" >> ${TMP2[$counter]}
        echo $r >> ${TMP2[$counter]}
        let counter++
    done
done
for file in ${TMP[*]};
do  
    echo '----------------' >> $file
done

cat ${TMP2[0]} >> ptrVet_aux.tmp
cat ${TMP2[1]} >> rowVet_aux.tmp
cat ${TMP2[2]} >> matPtr_aux.tmp
cat ${TMP2[3]} >> matRow_aux.tmp

for file in ${TMP2[*]};
do
    rm $file
done

for file in ${TMP[*]};
do
    echo '----------------' >> $file
    echo "N:Data cache miss ratio" >> $file
done
for N in 64 100 128;
do
    likwid-perfctr -C 3 -g L2CACHE -m $PROGRAM -n $N > aux.tmp
    RESULT=$(cat aux.tmp | grep "L2 miss ratio" | cut -d'|' -f3)
    RESULT=$(echo ${RESULT//$'\n'/})

    let counter=0
    for r in $RESULT;
    do
        echo -n "$N:" >> ${TMP[$counter]}
        echo $r >> ${TMP[$counter]}
        let counter++
    done
done
for file in ${TMP[*]};
do  
    echo '----------------' >> $file
done

for file in ${TMP[*]};
do  
    echo >> $file
    echo "N:MFLOP/s" >> $file
done
for N in 64 100 128;
do
    likwid-perfctr -C 3 -g FLOPS_DP -m "$PROGRAM -n $N" > aux.tmp
    RESULT=$(cat aux.tmp | grep -v "AVX" | grep "DP MFLOP/s" | cut -d'|' -f3)
    RESULT=$(echo ${RESULT//$'\n'/})

    let counter=0
    for r in $RESULT;
    do
        echo -n "$N:" >> ${TMP[$counter]}
        echo $r >> ${TMP[$counter]}
        let counter++
    done
done

for file in ${TMP[*]};
do
    column -s : -t $file
    rm $file
    echo
done

rm aux.tmp