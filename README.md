# bigdata-emr-report-processes

Project that creates an EMR cluster which launches all processes related to generation of reports

We can reprocessing Xsecurity Apolo's report from here, just need to create a pipeline using the variable "SECURITY_DATE"
DEFAULT OPTION (WITHOUT ANY VARIABLES) : COMPUTE THE LAST DAY (YESTERDAY)
VAR SECURITY_DATE = ALL : COMPUTE ALL DAYS FROM 2019-02-04 TO LAST DAY
VAR SECURITY_DATE = YYYY-MM-DD : COMPUTE SECURITY LOGS FOR THE SPECIFIED DAY
VAR SECURITY_DATE = ALL_FROM & VAR DATE_FROM = YYYY-MM-DD : COMPUTE SECURITY LOGS FROM SPECIFIED DAY TO ACTUAL DAY