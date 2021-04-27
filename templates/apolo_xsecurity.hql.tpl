set hive.execution.engine=tez;
set hive.auto.convert.join=true;
set hive.auto.convert.join.noconditionaltask=true;
set hive.auto.convert.join.noconditionaltask.size=405306368;
set hive.vectorized.execution.enabled=true;
set hive.vectorized.execution.reduce.enabled = true;
set hive.cbo.enable=true;
set hive.compute.query.using.stats=true;
set hive.stats.fetch.column.stats=true;
set hive.stats.fetch.partition.stats=true;
set hive.merge.mapfiles = true;
set hive.merge.mapredfiles=true;
set hive.merge.size.per.task=134217728;
set hive.merge.smallfiles.avgsize= 44739242;
set mapreduce.job.reduce.slowstart.completedmaps=0.7;


insert overwrite table orangex_${ENVIRONMENT}.report_apolo_xsecurity
partition(day='$${hiveconf:security_date}')
select 
ID_TIPO_SERVICIO_USO,
TIPO_SERVICIO_USO, 
date_format(start_s,'yyyy-MM-dd HH:mm:ss.SSS') as start_s,
unix_timestamp(stop_s) - unix_timestamp(start_s) as duracion,
date_format(stop_s,'yyyy-MM-dd HH:mm:ss.SSS') as stop_s,
lpad(split(source_translated_address, '\\.')[0],3,'0')||lpad(split(source_translated_address, '\\.')[1],3,'0')||lpad(split(source_translated_address, '\\.')[2],3,'0')||lpad(split(source_translated_address, '\\.')[3],3,'0') as source_translated_address,
source_translated_port,
transport_protocol,
'',
'',
client_id,
h.id
-- site_id
 from (
select '4' ID_TIPO_SERVICIO_USO,
'X Security' TIPO_SERVICIO_USO, 
min(cast(fecha as timestamp)) as start_s,
max(cast(fecha as timestamp)) as stop_s,
-- case
-- WHEN max(fecha) = min(fecha) THEN max(fecha) + INTERVAL '0.1' SECOND
-- ELSE max(fecha)
-- end stop_s,
source_translated_address,
source_translated_port,
client_id,
site_id, 
transport_protocol from (
SELECT 
 client_id,
 site_id,
 source_translated_address,
 source_translated_port,
 transport_protocol,
 fecha,
 SUM(a.is_new_session) OVER (PARTITION BY source_translated_address,source_translated_port ORDER BY cast(fecha as timestamp)) AS user_session_id
 FROM (
   select 
    client_id,site_id, fecha,fecha_prev,source_translated_address,source_translated_port,day,transport_protocol,
    case
    when client_id||site_id <> prev_client_id||prev_site_id then 1
    else 0 end as is_new_session
    from orangex_${ENVIRONMENT}.security_logs_day
    where day = date('$${hiveconf:security_date}')
    and  date(fecha) >= date('$${hiveconf:security_date}')
    and source_translated_address is not null
    and length(source_translated_address) > 0
    and length(source_translated_port) > 0
    and transport_protocol = '6'
  ) a
  )b
group by client_id,site_id,source_translated_address, source_translated_port,b.user_session_id,transport_protocol)c
join 
(select id,a.accountid from orangex_${ENVIRONMENT}.sf_asset a join (
SELECT accountid, MAX(ACTIVATION_DATE__C)fecha FROM orangex_${ENVIRONMENT}.SF_ASSET
WHERE upper(name) like '%SECURITY%'
AND STATUS = 'Activated'
and ACTIVATION_DATE__C < date('$${hiveconf:security_date}')
GROUP BY accountid) b on a.accountid = b.accountid and a.activation_date__c = b.fecha and upper(a.name) like '%SECURITY%') h on h.accountid = site_id
join 
(select * from (
select distinct id_servicio,id_cliente,estado_servicio, rank() over (partition by id_servicio,id_cliente order by day desc) as fcode from orangex_${ENVIRONMENT}.report_apolo_lineas
where day <= date('$${hiveconf:security_date}')  )d
where d.fcode = 1)k on k.id_servicio = h.id and k.id_cliente = client_id
where k.estado_servicio = 'A'
UNION ALL
select 
ID_TIPO_SERVICIO_USO,
TIPO_SERVICIO_USO, 
date_format(start_s,'yyyy-MM-dd HH:mm:ss.SSS') as start_s,
unix_timestamp(stop_s) - unix_timestamp(start_s) as duracion,
date_format(stop_s,'yyyy-MM-dd HH:mm:ss.SSS') as stop_s,
lpad(split(source_translated_address, '\\.')[0],3,'0')||lpad(split(source_translated_address, '\\.')[1],3,'0')||lpad(split(source_translated_address, '\\.')[2],3,'0')||lpad(split(source_translated_address, '\\.')[3],3,'0') as source_translated_address,
source_translated_port,
transport_protocol,
'',
'',
client_id,
j.id
-- site_id
 from (
select '4' ID_TIPO_SERVICIO_USO,
'X Security' TIPO_SERVICIO_USO, 
min(cast(fecha as timestamp)) as start_s,
max(cast(fecha as timestamp)) as stop_s,
-- case
-- WHEN max(fecha) = min(fecha) THEN max(fecha) + INTERVAL '0.1' SECOND
-- ELSE max(fecha)
-- end stop_s,
source_translated_address,
source_translated_port,
client_id,
site_id, 
transport_protocol from (
SELECT 
 client_id,
 site_id,
 source_translated_address,
 source_translated_port,
 transport_protocol,
 fecha,
 SUM(a.is_new_session) OVER (PARTITION BY source_translated_address,source_translated_port ORDER BY cast(fecha as timestamp)) AS user_session_id
 FROM (
   select 
    client_id,site_id, fecha,fecha_prev,source_translated_address,source_translated_port,day,transport_protocol,
    case
    when client_id||site_id <> prev_client_id||prev_site_id then 1
    else 0 end as is_new_session
    from orangex_${ENVIRONMENT}.security_logs_day
    where day = date('$${hiveconf:security_date}')
    and  date(fecha) >= date('$${hiveconf:security_date}')
    and source_translated_address is not null
    and length(source_translated_address) > 0
    and length(source_translated_port) > 0
    and transport_protocol = '17'
  ) a
  )b
group by client_id,site_id,source_translated_address, source_translated_port,b.user_session_id,transport_protocol)c
join 
(select id,a.accountid from orangex_${ENVIRONMENT}.sf_asset a join (
SELECT accountid, MAX(ACTIVATION_DATE__C)fecha FROM orangex_${ENVIRONMENT}.SF_ASSET
WHERE upper(name) like '%SECURITY%'
AND STATUS = 'Activated'
and ACTIVATION_DATE__C < date('$${hiveconf:security_date}')
GROUP BY accountid) b on a.accountid = b.accountid and a.activation_date__c = b.fecha and upper(a.name) like '%SECURITY%') j on j.accountid = site_id
join 
(select * from (
select distinct id_servicio,id_cliente,estado_servicio, rank() over (partition by id_servicio,id_cliente order by day desc) as fcode from orangex_${ENVIRONMENT}.report_apolo_lineas
where day <= date('$${hiveconf:security_date}')  )d
where d.fcode = 1)k on k.id_servicio = j.id and k.id_cliente = client_id
where k.estado_servicio = 'A'
order by source_translated_port,stop_s;

MSCK REPAIR TABLE orangex_${ENVIRONMENT}.report_apolo_xsecurity;