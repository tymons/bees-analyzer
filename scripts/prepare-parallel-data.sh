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
  DATA_RESULT_DIC+=/$3
fi

START_FILE_NAME_PATTERN='*'$1'*.csv'
END_FILE_NAME_PATTERN='*'$2'*.csv'

START_ID="$(find $DATA_ROOT_DIC/mic1 -name $START_FILE_NAME_PATTERN | awk -F'-' '{print $1}' | awk -F'/' '{print $11}')"
END_ID="$(find $DATA_ROOT_DIC/mic1 -name $END_FILE_NAME_PATTERN | awk -F'-' '{print $1}' | awk -F'/' '{print $11}')"

if [ -z "$START_ID" ] || [ -z "$END_ID" ]; then
    echo "One of id is null. Probably there is no data for one of the timestamps. Check again."
    exit
fi
NUM_OF_SOUNDS="$(($END_ID-$START_ID+1))";

echo "Your start and end ids are: $START_ID/$END_ID which gives you $NUM_OF_SOUNDS files"

for (( c=$START_ID; c<=$END_ID; c++ ))
do
   FILE="$(find $DATA_ROOT_DIC/mic1 -name '*'$c'*.csv')"
   cp $FILE $DATA_RESULT_DIC/
done
