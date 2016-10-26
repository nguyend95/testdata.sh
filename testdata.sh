#!/bin/bash

# Barvy
colorreset='\e[39m'
coloryellow='\e[33m'
colorblue='\e[34m'
colorcyan='\e[36m'
colorred='\e[31m'
colorgreen='\e[32m'

# Formatovani
formatboldreset='\e[21m'
formatbold='\e[1m'
formatunderline='\e[4m'
formatunderlinereset='\e[24m'

# Uvodni zprava
echo -e "\n"
echo -e "${formatbold}${colorcyan}Testovaci skript pro PA1${colorreset}${formatboldreset}"
echo -e "${colorblue}Jakub Jun 2016${colorreset}"
echo -e "${colorblue}https://github.com/jayjay221/testdata.sh${colorreset}"

# Argumenty
ARCHIV=$2
PROGRAM=$1
tmpdir="/tmp/testdata"

# Uklid po minule
if [ -d "$tmpdir" ];
then
rm -rf "$tmpdir"
fi

# Byly vubec zadany argumenty?
if [ -z "${2+xxx}" ];
then 
ARCHIV="sample.tgz"
echo "Nebyla uvedena cesta k archivu."
echo "Pouzivam implicitni archiv \"./sample.tgz\"."
fi

if [ -z "${1+xxx}" ];
then
PROGRAM="./a.out"
echo "Nebyla uvedena cesta k spustitelnemu souboru."
echo "Pouzivam implicitni program \"./a.out\""
fi

# Jsou cesty absolutni nebo relativni?
initialarch="$(echo $ARCHIV | head -c 1)"
initialprog="$(echo $PROGRAM | head -c 1)"

if [  "$initialarch" != "/" ];
then
ARCHIV="$(pwd)/$ARCHIV"
fi

if [  "$initialprog" != "/" ];
then
PROGRAM="$(pwd)/$PROGRAM"
fi

# Vytvorime si tmp adresare pro praci se soubory
mkdir "$tmpdir"
mkdir -p "$tmpdir/referencni_archiv" > "$tmpdir/log.txt" 2>&1
mkdir -p "$tmpdir/vysledky" >> "$tmpdir/log.txt" 2>&1

# Rozbalime archiv
tar -C "$tmpdir/referencni_archiv" -xvf "$ARCHIV" >> "$tmpdir/log.txt" 2>&1

# Pripravime pole s referencnimi vystupy
declare -a REFERVYS
# Iterator nastavime na 0
i=0

# Postupne si ulozime referencni vystupy do pole
for SOUBOR in `ls -v $tmpdir/referencni_archiv/CZE/*_out.txt`;
do
    REFERVYS[$i]="$SOUBOR"
    i=$((i+1))
done

# To same nyni s vstupy
declare -a REFERVSTUP
i=0

for SOUBOR in `ls -v $tmpdir/referencni_archiv/CZE/*_in.txt`;
do
    REFERVSTUP[$i]="$SOUBOR"
    i=$((i+1))
done

# A jeste s vystupy naseho programu
i=0
declare -a MYVYSTUP

for SOUBOR in ${REFERVSTUP[*]};
do
    ITER=`printf "%04d" $i`
    $PROGRAM < $SOUBOR > "$tmpdir/vysledky/${ITER}_myout.txt"
    MYVYSTUP[$i]="$tmpdir/vysledky/${ITER}_myout.txt"
    i=$((i+1))
done


# Spocitame chyby
chyby=0
i=0
for SOUBOR in ${REFERVYS[*]};
do
    # Porovnavame, pri rozdilu inkrementujeme $chyby
    diff "$SOUBOR" "${MYVYSTUP[$i]}" > "log.txt"  2>&1
    if [ $? == 1 ];
    then
        chyby=$((chyby+1))
    fi
    i=$((i+1))
done

# Oznamime vysledek
if [ $chyby == 0 ];
then
    # Uspech
    echo -e "${colorgreen}${formatbold}vse je v poradku${formatboldreset}${colorreset}"
else
    # Neuspech
    echo -e "${formatbold}${colorred}${formatunderline}$chyby${formatunderlinereset} vystupu nesedi${colorreset}${formatboldreset}"
fi
 
# Uklidime po sobe, nechame pouze adresar a v nem log
rm -rf "$tmpdir/referencni_archiv" >> "log.txt" 2>&1
rm -rf "$tmpdir/vysledky" >> "log.txt" 2>&1
