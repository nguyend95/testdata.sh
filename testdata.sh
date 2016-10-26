#!/bin/bash

ARCHIV=$2
PROGRAM=$1

if [ -z "${2+xxx}" ];
then 
ARCHIV="sample.tgz"
echo "nebyl zadan druhy parametr"
fi

if [ -z "${1+xxx}" ];
then
PROGRAM="./a.out"
echo "nebyl zadan prvni parametr"
fi

mkdir referencni_archiv > "log.txt" 2>&1
mkdir vysledky >> "log.txt" 2>&1

echo "referencni archiv je $ARCHIV"
tar -C "referencni_archiv" -xvf "$ARCHIV" >> "log.txt" 2>&1

declare -a REFERVYS
i=0

for SOUBOR in `ls -v referencni_archiv/CZE/*_out.txt`;
do
    REFERVYS[$i]="$SOUBOR"
    i=$((i+1))
done

declare -a REFERVSTUP
i=0

for SOUBOR in `ls -v referencni_archiv/CZE/*_in.txt`;
do
    REFERVSTUP[$i]="$SOUBOR"
    i=$((i+1))
done


i=0
declare -a MYVYSTUP

for SOUBOR in ${REFERVSTUP[*]};
do
    ITER=`printf "%04d" $i`
    # echo $ITER
    $PROGRAM < $SOUBOR > "vysledky/${ITER}_myout.txt"
    MYVYSTUP[$i]="vysledky/${ITER}_myout.txt"
    i=$((i+1))
done



chyby=0
i=0
for SOUBOR in ${REFERVYS[*]};
do
    diff "$SOUBOR" "${MYVYSTUP[$i]}" > "log.txt"  2>&1
    if [ $? == 1 ];
    then
        chyby=$((chyby+1))
    fi
    i=$((i+1))
done

if [ $chyby == 0 ];
then
    echo "vse je v poradku"
else
    echo "$chyby vystupu nesedi"
fi
 
rm -rf "referencni_archiv" >> "log.txt" 2>&1
rm -rf "vysledky" >> "log.txt" 2>&1
