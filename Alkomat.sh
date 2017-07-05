#!/bin/bash
# Autor: Karolina Maison
# Opis: Program pełniący funkcję wirtualnego alkomatu z dodatkową funkcją wizualizacją obrazu na podstawie ilości promili we krwi

source ./zmienne.sh
menu() #wyswietlenie menu
    {
    odp=$(zenity --list --column=Menu Formularz Podsumowanie Wizualizacja Autor "ZERUJ DANE" Wyjscie --height=300)
        if [ $? = '-1' ]; then
        exit
        fi
    if [[ $odp = "Formularz" ]];
    then
    formularz
    elif [[ $odp = "Podsumowanie" ]];
    then
    podsumowanie
    elif [[ $odp = "Autor" ]];
    then
    autor
    elif [[ $odp = "Wizualizacja" ]];
    then wizualizacja
    elif [[ $odp = "Wyjscie" ]];
    then exit
    else
    zeruj
    fi
    }

autor() # wyswietlenie autora skryptu
    {
    zenity --info --title "Alkomat" --text "Karolina Maison 165609"
    }

formularz() #uzupelnianie danych
{
    plec=$(zenity --list --radiolist  --column "" --column "Plec" true Kobieta false Mezczyzna --cancel-label "Powrot do menu" --ok-label "Dalej")
    if [ $? = '1' ]; then
    menu
    break
    else
    text="Jestes "$plec""
    fi
    wiek=$(zenity --scale --title "Alkomat" --text "Wiek" --min-value 16 --max-value 99 --value 20 --cancel-label "Powrot od menu" --ok-label "Dalej")
    if [ $? = '1' ]; then
    menu
    break
    else
    text=""$text", masz $wiek lat,"
    fi
    waga=$(zenity --scale --title "Alkomat" --text "Waga" --min-value 40 --max-value 150 --value 60 --cancel-label "Powrot od menu" --ok-label "Dalej")
    if [ $? = '1' ]; then
    menu
    break
    else
    text=""$text", wazysz $waga kg"
    fi
    wzrost=$(zenity --scale --title "Alkomat" --text "Wzrost" --min-value 120 --max-value 210 --value 170 --cancel-label "Powrot do menu" --ok-label "Dalej")
    if [ $? = '1' ]; then
    menu
    break
    else
    text="$text i masz "$wzrost"cm wzrostu."
    fi
    trwalo=$(zenity --scale --title "Alkomat" --text "Ile godzin piles?" --min-value 0 --max-value 48 --value 2 --cancel-label "Powrot do menu" --ok-label "Dalej")
    if [ $? = '1' ]; then
    menu
    break
    else
    text="$text Piles alkohol przez $trwalo h"
    fi

    niepije=$(zenity --scale --title "Alkomat" --text "Od ilu godzin juz nie pijesz?" --min-value 1 --max-value 24 --value 2 --cancel-label "Powrot do menu" --ok-label "Dalej")
    if [ $? = '1' ]; then
    menu
    break
    else
    text="$text i nie pijesz juz od $niepije h"
    fi

    podsumowanie
    listatrunkow
}


listatrunkow() #lista alkoholi z mozliwoscia dodania
{
    TPROCENTY=( )
    i=0
    proc=0
    poj=0
    while read linia; do #czytanie z pliku alkoholi
    TPROCENTY[$i]="$linia"
    i=$(($i+1))
    if [ `expr $i % 2` != '0' ]; then
        proc=$linia
    else
        poj=$linia
        A=$((A+poj*proc*79))

    fi
    done <"alkohol.txt"
    zenity --list --separator ";" --column "Ile % ma dany alkohol" --column "Ilosc ml" ${TPROCENTY[@]} --height=230 --width=320 --cancel-label "Dodaj" --ok-label "Dalej"

if [ $? = "1" ]; then
    dodaj
else
    if [ $i -gt 0 ]; then
    obliczanie
    else 
    listatrunkow
    fi
    fi
}

dodaj() #dodawanie do listy alkoholi z zapisem do pliku
    {
    proc=$(zenity --scale --title "Alkomat" --text "Jak wysoko procentowy alkohol piłeś?" --min-value 0 --max-value 100 --value 5)
        echo $proc>>alkohol.txt
    il=$(zenity --scale --title "Alkomat" --text "Ile wypiles tego alkoholu? (Wartosc podana w ml)" --min-value 25  --max-value 2000 --step 25 --value 50)
echo $il>>alkohol.txt
   
 listatrunkow
    }
podsumowanie() #wyswietlenie podsumowania 
    {
    zenity --info --title "Alkomat" --text "$text"
    }

obliczanie() #obliczanie ilosci promoili we krwi na podstawie danychodanych w formularzu
{
ALKOHOL=$A
if [ $plec = "Kobieta" ];then
    TBW=$((107*$wzrost+247*$waga-2097))
else
    TBW=$((2447+107*$wzrost+336*$waga-(91*$wiek)))
fi
TBW=$((TBW/100))
ALKOHOL=$((ALKOHOL/100))
PROMILE=$((80*$ALKOHOL/$TBW-($trwalo+$niepije)*15*10))
if [ $PROMILE -gt 99 ]; then
    CZ_CALK=$((PROMILE/1000))
    CZ_ULAMK=$((PROMILE-CZ_CALK*1000))
    if [ $CZ_ULAMK -lt 10 ]; then
       CZ_ULAMK="00$CZ_ULAMK"
    elif [ $CZ_ULAMK -lt 100 ]; then
        CZ_ULAMK="0$CZ_ULAMK"
    fi
    GODZINY=0
    while [ $PROMILE -gt 200 ]; do
    PROMILE=$((PROMILE-150))
    GODZINY=$((GODZINY+1))
    done
    
    DIR=`pwd`
    if [ $GODZINY -gt 0 ]; then
    if [ $CZ_CALK -gt 5 ]; then
    text="$text. Masz ponad 5 promili!"
    eog "smierc.jpg"
    else
    text="$text. Twoj wynik to:  $CZ_CALK,$CZ_ULAMK. Mozesz prowadzic za: $GODZINY h"
    eog "pijany.jpg"
    fi
    else
    text="$text. Twoj wynik to:  $CZ_CALK,$CZ_ULAMK. Mozesz prowadzic, ale bądz ostrozny."
    eog "trzezwy1.png"
    fi
    else 
    text="$text. JESTES TRZEŹWY! MOŻESZ PROWADZIĆ! $CZ_CALK,$CZ_ULAMK"
    eog "trzezwy1.png"
fi
podsumowanie
}

wizualizacja() #Wyswietlenie okienka z wyborem obrazu do rozmycia
{
FILE=`zenity --file-selection --title="ALKOMAT" --file-filter=""*.jpg" "*.png" "*.jpeg""`
ZNAK=$?
case $ZNAK in
         0)
                blur;;
         1)
                echo "BRAK PLIKU";;
        -1)
                echo "An unexpected error has occurred.";;
esac
}
blur() #wyswietlenie oraz zapisanie zdjecia oryginalnego i rozmytego zdjecia na podstawie ilosci promili we krwi 
{
Ile=$(zenity --list --column="Ile promili alkoholu we krwi?" 0.00-0.50 1.01-1.50 1.51-2.00 2.01-2.50 ">2.51" --height=300)

if [[ $Ile =~ ^0\.00-0\.50.* ]]; then
I=0x1
elif [[ $Ile =~ ^1\.01-1\.50.* ]]; then
I=0x2
elif [[ $Ile =~ ^1\.51-2\.00.* ]]; then
I=0x3
elif [[ $Ile =~ ^2\.01-2\.50.* ]]; then
I=0x4
else
I=0x8
fi

NAZWA=$(basename "${FILE}")
NAZWAB=$FILE.blur
NAZWAILE=$Ile-$NAZWA
convert $FILE -blur $I $NAZWAB #rozmycie zdjecia
convert $FILE $NAZWAB +append $NAZWAILE #przyklejenie 2 zdjecia
eog $NAZWAILE #wyswitlenie 
}

zeruj(){
zenity --question --title "Alkomat" --text "Czy jestes pewny ze chcesz usunac wszystkie dane?" cancel-label "Nie" --ok-label "Tak"
if [ $? = '0' ]; then
start=' '
waga=' '
wzrost=' '
trwalo=0
wiek=0
plec=' '
text=" "
A=0
odp=" "
niepije=0
>alkohol.txt
FILE=' '
PROMILE=0
CZ_ULAMK=0
CZ_CALK=0
fi
menu
}
while [[ $odp != "Wyjscie" ]]; do
menu
done
