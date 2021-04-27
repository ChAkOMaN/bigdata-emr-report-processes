#!/bin/sh

#Get script
aws s3 cp s3://${BUCKET}/hive_scripts/security_logs_day.hql security_logs_day.hql

#If SECURITY_DATE is not defined execute for TODAY
if [ -z "$SECURITY_DATE" ]; then
  echo "Auto Single date Execution"
  export SECURITY_DATE=$(date --date "yesterday" +%Y-%m-%d)
    echo $SECURITY_DATE
  hive --hiveconf security_date=$SECURITY_DATE -f security_logs_day.hql
#If SECURITY_DATE=ALL execute for all DATES
elif [ "$SECURITY_DATE" = "ALL" ]; then
  echo "ALL date Execution"

  init_date=$(date -I -d 2019-02-04)
  final_date=$(date --date "yesterday" +%Y-%m-%d)
  while [[ "$final_date" > "$init_date" ]]; do
    echo $init_date
    hive --hiveconf security_date=$init_date -f security_logs_day.hql
    init_date=$(date -I -d "$init_date + 1 day")
  done
 #IF SECURITY_DATE=ALL_FROM executes for all days from DATE_FROM TO today
elif [ "$SECURITY_DATE" = "ALL_FROM" ]; then
  echo "Execution from one determined date to today"
  echo $DATE_FROM
  init_date=$DATE_FROM
  echo init_date
  final_date=$(date --date "yesterday" +%Y-%m-%d)
  while [[ "$final_date" > "$init_date" ]]; do
    echo "dentro del bucle"
    echo $init_date
    hive --hiveconf security_date=$init_date -f security_logs_day.hql
    init_date=$(date -I -d "$init_date + 1 day")
  done
else
  echo "Manual Single date Execution"
  echo $SECURITY_DATE
  hive --hiveconf security_date=$SECURITY_DATE -f security_logs_day.hql
fi