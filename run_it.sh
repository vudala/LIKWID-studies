PROGRAM=./matmult

# inicializa os arquivos auxiliares 
TMP=( ptrVet_aux.tmp rowVet_aux.tmp matPtr_aux.tmp matRow_aux.tmp )
echo "multMatPtrVet" > ptrVet_aux.tmp
echo "multMatRowVet" > rowVet_aux.tmp
echo "multMatMatPtr" > matPtr_aux.tmp
echo "multMatMatRow" > matRow_aux.tmp

for file in ${TMP[*]};
do
    echo "N:Memory bandwidth [MBytes/s]" >> $file
done

TMP2=( ptrVet_aux2.tmp rowVet_aux2.tmp matPtr_aux2.tmp matRow_aux2.tmp )
for file in ${TMP2[*]};
do
    echo '----------------' > $file
    echo "N:Time elapsed [s]" >> $file
done

# monitora a banda de memória das funções
for N in 64 100 128 2000 2048;
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

    # captura o tempo de execução das funções para ser escrito posteriormente
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

# concatena os arquivo auxiliares
cat ${TMP2[0]} >> ptrVet_aux.tmp
cat ${TMP2[1]} >> rowVet_aux.tmp
cat ${TMP2[2]} >> matPtr_aux.tmp
cat ${TMP2[3]} >> matRow_aux.tmp
rm ${TMP2[*]}

# monitora a taxa de cache miss das funções
for file in ${TMP[*]};
do
    echo '----------------' >> $file
    echo "N:Data cache miss ratio" >> $file
done
for N in 64 100 128 2000 2048;
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


# monitora os MFLOPS/s de cada uma das funções
for file in ${TMP[*]};
do  
    echo '----------------' >> $file
    echo "N:DP MFLOP/s:AVX DP MFLOP/s" >> $file
done
for N in 64 100 128 2000 2048;
do
    likwid-perfctr -C 3 -g FLOPS_DP -m "$PROGRAM -n $N" > aux.tmp
    RESULT_DP=$(cat aux.tmp | grep -v "AVX" | grep "DP MFLOP/s" | cut -d'|' -f3)
    RESULT_DP=$(echo ${RESULT_DP//$'\n'/})

    RESULT_AVX=$(cat aux.tmp | grep "AVX" | cut -d'|' -f3)
    RESULT_AVX=$(echo ${RESULT_AVX//$'\n'/})

    let counter=0
    for r in $RESULT_DP;
    do
        echo -n "$N:" >> ${TMP[$counter]}
        echo -n $r: >> ${TMP[$counter]}
        let counter++
    done

    let counter=0
    for r in $RESULT_AVX;
    do
        echo $r >> ${TMP[$counter]}
        let counter++
    done
done

# deixa os arquivos bonitinhos pra apresentação
for file in ${TMP[*]};
do
    column -s : -t $file
    rm $file
    echo
done

rm aux.tmp
