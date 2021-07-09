TMP=( ptrVet_aux.tmp rowVet_aux.tmp matPtr_aux.tmp matRow_aux.tmp )

echo "multMatPtrVet" > ptrVet_aux.tmp
echo "multMatRowVet" > rowVet_aux.tmp
echo "multMatMatPtr" > matPtr_aux.tmp
echo "multMatMatRow" > matRow_aux.tmp

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
done

for file in ${TMP[*]};
do
    echo >> $file
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