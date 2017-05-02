#!/bin/bash
RED=$(tput setaf 1)
RESET=$(tput sgr0)
echo -e "${RED}\nTHIS IS SCRIPT FOR PREPARING DATA TO ANALYSIS. BE SURE THAT ALL DATA IS READY!!!\n${RESET}"

DATA_ROOT_DIC='/home/tymons/Projects/003.eUL/workspace/Ranalysis/data/csvresults'
DATA_RESULT_DIC='/home/tymons/Projects/003.eUL/workspace/Ranalysis/data/temp'
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "You didnt specify start/end date"
    exit
fi

if [ -z "$3" ]; then
  echo "You didnt specify catalog name"
  exit
else
  if [ -d "$DATA_RESULT_DIC/$3" ]; then
    rm -rf "$DATA_RESULT_DIC/$3"
  fi
  mkdir "$DATA_RESULT_DIC/$3"
fi

START_FILE_NAME_PATTERN='*'$1'*.csv'
END_FILE_NAME_PATTERN='*'$2'*.csv'

START_ID="$(find $DATA_ROOT_DIC/mic1 -name $START_FILE_NAME_PATTERN | awk -F'-' '{print $1}' | awk -F'/' '{print $11}')"
END_ID="$(find $DATA_ROOT_DIC/mic1 -name $END_FILE_NAME_PATTERN | awk -F'-' '{print $1}' | awk -F'/' '{print $11}')"

if [ -z "$START_ID" ] || [ -z "$END_ID" ]; then
    printf "One of id is null. Probably there is no data for one of the timestamps. Check again."
    exit
fi
NUM_OF_SOUNDS="$(($END_ID-$START_ID+1))";

echo "Your start and end ids are: $START_ID/$END_ID which gives you $NUM_OF_SOUNDS files."

# Create temperature/hum file
echo "Preparing to downloading temperatures..."
python3 temperature.py -s $1 -e $2
echo -e "Done!\n"
echo "Preparing to downloading humidities..."
python3 humidity.py -s $1 -e $2
echo -e "Done!\n"

TEMP_FILE_NAME="$(ls $DATA_ROOT_DIC/thermal/temperature | grep "$1" | grep "$2" | grep ".csv")"
HUM_FILE_NAME="$(ls $DATA_ROOT_DIC/thermal/humidity | grep "$1" | grep "$2"| grep ".csv")"

echo "Searching $TEMP_FILE_NAME and $HUM_FILE_NAME for proper values..."

for (( c=$START_ID; c<=$END_ID; c++ ))
do
   FILE="$(find $DATA_ROOT_DIC/mic1 -name $c'*.csv')"
   if [ -z "$FILE" ]; then
     echo "DAFUQ? missing ($FILE) FILE? File: $c'*.csv' Skipping.. "
     continue
   fi
   DATE_T="$(echo $FILE | awk -F'-' '{print $2 "-" $3 "-" $4}')"
   DATE="$(echo "$DATE_T" | tr '[T]' ' ')"
   DATE_WITHOUT_SEC=$(echo $DATE | awk -F':' '{print $1 ":" $2}')
   ROW_TEMP="$(cat "$DATA_ROOT_DIC/thermal/temperature/$TEMP_FILE_NAME" | grep "$DATE" | awk -F',' '{print $1}')"
   ROW_HUM="$(cat "$DATA_ROOT_DIC/thermal/humidity/$HUM_FILE_NAME" | grep "$DATE" | awk -F',' '{print $1}')"
   ROW_OUTDOOR=$(cat "$DATA_ROOT_DIC/thermal/thermal-outdoor/thermal-koteze.csv" | grep -a "$DATE_WITHOUT_SEC")
   ROW_OUTDOOR_TEMP=$(echo $ROW_OUTDOOR | awk -F',' '{print $1}')
   ROW_OUTDOOR_HUM=$(echo $ROW_OUTDOOR | awk -F',' '{print $2}')
   ROW_OUTDOOR_PRESS=$(echo $ROW_OUTDOOR | awk -F',' '{print $3}')

   if [ -z "$ROW_OUTDOOR_TEMP" ]; then
     # There is missing entry for that time, round thermal to one hour
     DATE_WITHOUT_SEC=$(echo $DATE | awk -F':' '{print $1}')
     ROW_OUTDOOR=$(cat "$DATA_ROOT_DIC/thermal/thermal-outdoor/thermal-koteze.csv" | grep -a "$DATE_WITHOUT_SEC")
     ROW_OUTDOOR_TEMP=$(echo $ROW_OUTDOOR | awk -F',' '{print $1}')
     ROW_OUTDOOR_HUM=$(echo $ROW_OUTDOOR | awk -F',' '{print $2}')
     ROW_OUTDOOR_PRESS=$(echo $ROW_OUTDOOR | awk -F',' '{print $3}')
     if [ -z "$ROW_OUTDOOR" ]; then
        echo "MISSING OUTDOOR THERMAL DATA FOR $DATE_WITHOUT_SEC ! Update this manually."
     fi
   fi

   if [ -z "$ROW_TEMP" ]; then
     echo "MISSING TEMPERATURE FOR $DATE ! Update this manually."
   fi

   if [ -z "$ROW_HUM" ]; then
     echo "MISSING HUMIDITY FOR $DATE ! Update this manually."
   fi

   echo "$ROW_TEMP" >> "$DATA_RESULT_DIC/$3/temperatures.csv"
   echo "$ROW_HUM" >> "$DATA_RESULT_DIC/$3/humidities.csv"
   echo "$ROW_OUTDOOR_TEMP" >> "$DATA_RESULT_DIC/$3/temperature-outdoor.csv"
   echo "$ROW_OUTDOOR_HUM" >> "$DATA_RESULT_DIC/$3/humidities-outdoor.csv"
   echo "$ROW_OUTDOOR_PRESS" >> "$DATA_RESULT_DIC/$3/pressure-outdoor.csv"
   # Copy sound value
   IDX=$(($IDX+1))
   cp $FILE "$DATA_RESULT_DIC/$3/$IDX.csv"
done

echo "Done! Results are in "$DATA_RESULT_DIC/$3" directory"
