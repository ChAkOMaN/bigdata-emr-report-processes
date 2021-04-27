#!/bin/sh
echo "entrada script"
#Get script
aws s3 cp s3://orange-x.smartlead-$ENVIRONMENT/hive_scripts/apolo_address.hql apolo_address.hql
echo "despues de copia hql script"
#If AP_ADDRESS_DATE is not defined execute for TODAY
if [ -z "$AP_ADDRESS_DATE" ]; then
  echo "Auto Single date Execution"
  export AP_ADDRESS_DATE=$(date +%Y-%m-%d)
    echo $AP_ADDRESS_DATE
  hive --hiveconf ap_address_date=$AP_ADDRESS_DATE -f apolo_address.hql
#If AP_ADDRESS_DATE=ALL execute for all DATES
elif [ "$AP_ADDRESS_DATE" = "ALL" ]; then
  echo "ALL date Execution"

  init_date=$(date -I -d 2019-02-04)
  final_date=$(date +%Y-%m-%d)
  while [[ "$final_date" > "$init_date" ]]; do
    echo $init_date
    hive --hiveconf ap_address_date=$init_date -f apolo_address.hql
    init_date=$(date -I -d "$init_date + 1 day")
  done
else
  echo "Manual Single date Execution"
  echo $AP_ADDRESS_DATE
  hive --hiveconf ap_address_date=$AP_ADDRESS_DATE -f apolo_address.hql
fi