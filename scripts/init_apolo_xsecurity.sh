#!/bin/sh
echo "entrada script"
#Get script
aws s3 cp s3://orange-x.smartlead-$ENVIRONMENT/hive_scripts/apolo_xsecurity.hql apolo_xsecurity.hql
echo "despues de copia hql script"
#If SECURITY_DATE is not defined execute for TODAY
if [ -z "$SECURITY_DATE" ]; then
  echo "Auto Single date Execution"
  export SECURITY_DATE=$(date --date "yesterday" +%Y-%m-%d)
    echo $SECURITY_DATE
  hive --hiveconf security_date=$SECURITY_DATE -f apolo_xsecurity.hql
#If SECURITY_DATE=ALL execute for all DATES
elif [ "$SECURITY_DATE" = "ALL" ]; then
  echo "ALL date Execution"

  init_date=$(date -I -d 2019-02-04)
  final_date=$(date --date "yesterday" +%Y-%m-%d)
  while [[ "$final_date" > "$init_date" ]]; do
    echo $init_date
    hive --hiveconf security_date=$init_date -f apolo_xsecurity.hql
    init_date=$(date -I -d "$init_date + 1 day")
  done
else
  echo "Manual Single date Execution"
  echo $SECURITY_DATE
  hive --hiveconf security_date=$SECURITY_DATE -f apolo_xsecurity.hql
fi