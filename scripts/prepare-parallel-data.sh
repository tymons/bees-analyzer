#!/bin/bash

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
   FILE="$(find $DATA_ROOT_DIC/mic1 -name '*'$c'*.csv')"
   DATE_T="$(find $DATA_ROOT_DIC/mic1 -name '*'$c'*.csv' | awk -F'-' '{print $2 "-" $3 "-" $4}')"
   DATE="$(echo "$DATE_T" | tr '[T]' ' ')"
   ROW="$(cat "$DATA_ROOT_DIC/thermal/temperature/$TEMP_FILE_NAME" | grep "$DATE" | awk -F',' '{print $1}')"
   echo "$ROW" >> "$DATA_RESULT_DIC/$3/temperatures.csv"
   cp $FILE "$DATA_RESULT_DIC/$3/$(($c-$START_ID)).csv"
done

echo "Done! Results are in "$DATA_RESULT_DIC/$3" directory"
