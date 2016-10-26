#!/bin/bash

colorreset='\e[39m'
coloryellow='\e[33m'
colorblue='\e[34m'
colorcyan='\e[36m'
colorred='\e[31m'
colorgreen='\e[32m'

formatboldreset='\e[21m'
formatbold='\e[1m'
formatunderline='\e[4m'
formatunderlinereset='\e[24m'

echo -e "\n"
echo -e "${formatbold}${colorcyan}Testovaci skript pro PA1${colorreset}${formatboldreset}"
echo -e "${colorblue}Jakub Jun 2016${colorreset}"

ARCHIV=$2
PROGRAM=$1
tmpdir="/tmp/testdata"


if [ -d "$tmpdir" ];
then
rm -rf "$tmpdir"
fi

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

initialarch="$(echo $ARCHIV | head -c 1)"
initialprog="$(echo $PROGRAM | head -c 1)"

if [  "$initialarch" != "/" ];
then
ARCHIV="$(pwd)/$ARCHIV"
fi


if [  "$initialprog" != "/" ];
then
PROGRAM="$(pwd)/$PROGRAM"
# echo "$PROGRAM"
fi
mkdir "$tmpdir"
mkdir -p "$tmpdir/referencni_archiv" > "$tmpdir/log.txt" 2>&1
mkdir -p "$tmpdir/vysledky" >> "$tmpdir/log.txt" 2>&1

# echo "referencni archiv je $ARCHIV"
tar -C "$tmpdir/referencni_archiv" -xvf "$ARCHIV" >> "$tmpdir/log.txt" 2>&1

declare -a REFERVYS
i=0

for SOUBOR in `ls -v $tmpdir/referencni_archiv/CZE/*_out.txt`;
do
    REFERVYS[$i]="$SOUBOR"
    i=$((i+1))
done

declare -a REFERVSTUP
i=0

for SOUBOR in `ls -v $tmpdir/referencni_archiv/CZE/*_in.txt`;
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
    $PROGRAM < $SOUBOR > "$tmpdir/vysledky/${ITER}_myout.txt"
    MYVYSTUP[$i]="$tmpdir/vysledky/${ITER}_myout.txt"
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
    echo -e "${colorgreen}${formatbold}vse je v poradku${formatboldreset}${colorreset}"
else
    echo -e "${formatbold}${colorred}${formatunderline}$chyby${formatunderlinereset} vystupu nesedi${colorreset}${formatboldreset}"
fi
 
rm -rf "$tmpdir/referencni_archiv" >> "log.txt" 2>&1
rm -rf "$tmpdir/vysledky" >> "log.txt" 2>&1
