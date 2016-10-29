#!/bin/bash

# TODO
# vyrobit funkce!!!
# funkce pro barvy
# je to docela bordel tedka
# konfiguracni soubor
# prizpusobit format diffu (problem asi)
# pouzit printf misto echo
# zavest log do FS


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
 
tucne () {
    echo -en '\e[1m'"$1"'\e[21m'
}
podtrzene () {
    echo -en '\e[4m'"$1"'\e[24m'
}
cervena () {
    echo -en '\e[31m'"$1"'\e[39m'
}
modra () {
    echo -en '\e[34m'"$1"'\e[39m'
}
zelena () {
    echo -en '\e[32m'"$1"'\e[39m'
}

# Funkce pro uklid
uklid () {
    if [ -d "$tmpdir" ];
    then
        rm -rf "$tmpdir"
    fi
}

# Funkce pro terminaci
term () {
    chyba "$2"
    exit "$1"
}

# Funkce vypisuje chyby
chyba () {
    echo -e "${formatbold}${colorred}${formatunderline}ERROR${formatunderlinereset}: $1${colorreset}${formatboldreset}"
}

# Uvodni zprava
echo -e "${formatbold}${colorcyan}Testovaci skript pro PA1${colorreset}${formatboldreset}"
echo -e "${colorblue}Jakub Jun 2016${colorreset}"
echo -e "${colorblue}https://github.com/jayjay221/testdata.sh${colorreset}"

# Argumenty
ARCHIV=$2
PROGRAM=$1
tmpdir="/tmp/testdata"

# Byly vubec zadany argumenty?
if [ -z "${2+xxx}" ];
then 
ARCHIV="sample.tgz"
#echo "Nebyla uvedena cesta k archivu."
#echo "Pouzivam implicitni archiv \"./sample.tgz\"."
fi

if [ -z "${1+xxx}" ];
then
PROGRAM="./a.out"
#echo "Nebyla uvedena cesta k spustitelnemu souboru."
#echo "Pouzivam implicitni program \"./a.out\""
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

# Existuji soubory?
if [ ! -e "$PROGRAM" ]
then
    term "5" "\"$PROGRAM\" neexistuje"
fi

if [ ! -e "$ARCHIV" ]
then
    term "5" "\"$ARCHIV\" neexistuje"
fi

# Vytvorime si tmp adresare pro praci se soubory
if  ! mkdir "$tmpdir" > "/dev/null" 2>&1 ;
then
    term "1" "Nelze vytvorit \"$tmpdir\""
fi
if  ! mkdir -p "$tmpdir/referencni_archiv" > "/dev/null" 2>&1 ;
then
    term "1" "Nelze vytvorit \"$tmpdir/referencni_archiv\""
fi
if  ! mkdir -p "$tmpdir/vysledky" > "/dev/null" 2>&1 ;
then
    term "1" "Nelze vytvorit \"$tmpdir/vysledky\""
fi

# Rozbalime archiv
if  ! tar -C "$tmpdir/referencni_archiv" -xvf "$ARCHIV" > "/dev/null" 2>&1 ;
then
    term "2" "Nelze rozbalit \"$ARCHIV\" do \"$tmpdir/referencni_archiv\""
fi

# Pripravime pole s referencnimi vystupy
declare -a REFERVYS
# Iterator nastavime na 0
i=0

# Postupne si ulozime referencni vystupy do pole
for SOUBOR in $(ls -v $tmpdir/referencni_archiv/CZE/*_out.txt);
do
    REFERVYS[$i]="$SOUBOR"
    i=$((i+1))
done

# To same nyni s vstupy
declare -a REFERVSTUP
i=0

for SOUBOR in $(ls -v $tmpdir/referencni_archiv/CZE/*_in.txt);
do
    REFERVSTUP[$i]="$SOUBOR"
    i=$((i+1))
done

# A jeste s vystupy naseho programu
i=0
declare -a MYVYSTUP

for SOUBOR in ${REFERVSTUP[*]};
do
    ITER=$(printf "%04d" $i)
    # Nasledujici prikaz potreba osetrit.
    $PROGRAM < $SOUBOR > "$tmpdir/vysledky/${ITER}_myout.txt" ;
    MYVYSTUP[$i]="$tmpdir/vysledky/${ITER}_myout.txt"
    i=$((i+1))
done


# Spocitame chyby
chyby=0
declare -a ROZDILY
i=0
for SOUBOR in ${REFERVYS[*]};
do
    echo -en "${colorcyan}${formatbold}Vystup $i:${formatboldreset}${colorreset}"
    # Porovnavame, pri rozdilu inkrementujeme $chyby
    ROZDILY[$i]="$(diff "$SOUBOR" "${MYVYSTUP[$i]}" 2>&1)"
    if [ $? == 1 ];
    then
        echo -e " ${colorred}${formatbold}CHYBA${formatboldreset}${colorreset}"
        chyby=$((chyby+1))
    else
        ROZDILY[$i]=""
        echo -e " ${colorgreen}${formatbold}OK${formatboldreset}${colorreset}"
    fi
    i=$((i+1))
done

echo -e "${colorcyan}${formatbold}--------------${formatboldreset}${colorreset}"
i=0
for ROZDIL in "${ROZDILY[@]}";
do
    if [ "$ROZDIL" != "" ];
    then
        echo -e "${colorred}${formatbold}Vystup $((i)) [${coloryellow}$(basename ${REFERVYS[i]})${colorred}]${formatboldreset}${colorreset}"
        echo -e "${coloryellow}----------------${colorreset}"
        echo "$ROZDIL"
        echo -e "${coloryellow}----------------${colorreset}"
        
    fi
    i=$(($i+1))
done

# Oznamime vysledek
if [ $chyby == 0 ];
then
    # Uspech
    echo -e "${colorgreen}${formatbold}vse je v poradku${formatboldreset}${colorreset}"
else
    # Neuspech
    echo -e "${colorcyan}${formatbold}--------------${formatboldreset}${colorreset}"
    echo -e "${formatbold}${colorred}${formatunderline}$chyby${formatunderlinereset} vystupu nesedi${colorreset}${formatboldreset}"
fi
 
# Uklidime po sobe
if  ! rm -rf "$tmpdir" > "/dev/null" 2>&1 ;
then
    term "4" "Nelze smazat \"$tmpdir\""
fi

exit 0
