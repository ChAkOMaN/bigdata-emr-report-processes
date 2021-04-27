#!/bin/bash

ENVIRONMENT=$1
DATE=$2

if [ -z "$DATE" ]; then
	DATE=$(date --date "yesterday" +%Y-%m-%d)
fi

YEAR=$(echo "$DATE" | cut -c 1-4)
MONTH=$(echo "$DATE" | cut -c 6-7)
DAY=$(echo "$DATE" | cut -c 9-10)

echo $DATE
INPUT_PATH=s3://orange-x.smartlead-production/es_cybersecurity/$YEAR/$MONTH/$DAY/

if [ "${ENVIRONMENT}" = "production" ]; then
#extract
for file in `aws s3 ls s3://orange-x.smartlead-production/es_cybersecurity/$YEAR/$MONTH/$DAY/|rev | cut -d ' ' -f -1 |rev`; do aws s3 cp  s3://orange-x.smartlead-production/es_cybersecurity/$YEAR/$MONTH/$DAY/$file input_production/$file; done

#cleaning
for i in input_production/*; do sed -i 's/\\n/ /g' $i; done

#load
for file in input_production/*.txt; do aws s3 cp $file s3://orange-x.smartlead-production/es_cybersecurity_cleaned/$YEAR/$MONTH/$DAY/$(echo $file | cut -f2 -d'/'); done

fi

exit 0