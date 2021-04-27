USE orangex_${ENVIRONMENT};
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
set mapreduce.map.memory.mb=5120;
set mapreduce.map.java.opts=-Xmx6144m;
set mapreduce.reduce.memory.mb=5120;
set mapreduce.reduce.java.opts=-Xmx6144m;

DROP TABLE IF EXISTS `orangex_${ENVIRONMENT}.security_temp`;

CREATE EXTERNAL TABLE IF NOT EXISTS `orangex_${ENVIRONMENT}.security_temp` (
   fecha string
  ,key string
  )
ROW FORMAT SERDE 'org.apache.hadoop.hive.ql.io.orc.OrcSerde'
WITH SERDEPROPERTIES('timestamp.formats'='yyyy-MM-dd HH:mm:ss.SSS')
STORED AS orc
LOCATION 's3://${BUCKET}/security_temp'
TBLPROPERTIES ("orc_compress"="NONE",'serialization.null.format'='');

ALTER TABLE orangex_${ENVIRONMENT}.security_temp SET SERDEPROPERTIES ("timestamp.formats"="yyyy-MM-dd HH:mm:ss.SSS");

INSERT OVERWRITE TABLE orangex_${ENVIRONMENT}.security_temp
select date_format(fecha,'yyyy-MM-dd HH:mm:ss.SSS')fecha,key from (
select date_format(fecha,'yyyy-MM-dd HH:mm:ss.SSS')fecha,source_translated_port||transport_protocol as key, count(*) from (
select distinct client_id,source_translated_port,transport_protocol,date_format(fecha,'yyyy-MM-dd HH:mm:ss.SSS')fecha from orangex_${ENVIRONMENT}.security_addresses
where day = date('$${hiveconf:security_date}')
and transport_protocol in ('6','17')
and source_translated_port is not null)h1
group by fecha,source_translated_port,transport_protocol having count(*) > 1)col;


-- DROP TABLE IF EXISTS `orangex_${ENVIRONMENT}.security_logs_day`;

CREATE EXTERNAL TABLE IF NOT EXISTS `orangex_${ENVIRONMENT}.security_logs_day` (
   fecha string COMMENT 'fecha_movimiento'
  ,fecha_prev string COMMENT 'fecha_movimiento anterior'
  ,client_id string COMMENT 'id interna del cliente'
  ,site_id string COMMENT 'site del Cliente'
  ,real_source_address string COMMENT 'ip privada'
  ,real_source_port string COMMENT 'puerto ip privada'
  ,source_translated_address string COMMENT 'ip publica'
  ,source_translated_port string COMMENT 'puerto ip publica'
  ,destination_address string COMMENT 'ip navegacion'
  ,destination_port string COMMENT 'ip puerto navegacion'
  ,prev_source string COMMENT 'ip privada movimiento anterior'
  ,prev_real_port string COMMENT 'puerto ip privada movimiento anterior'
  ,prev_client_id string COMMENT 'client id movimiento anterior'
  ,prev_site_id string COMMENT 'site id movimiento anterior'
  ,transport_protocol string COMMENT 'protocolo de la conexion'
  )
PARTITIONED BY (day date)
STORED AS orc
LOCATION 's3://${BUCKET}/security_logs'
TBLPROPERTIES ("orc_compress"="NONE",'serialization.null.format'='');

ALTER TABLE orangex_${ENVIRONMENT}.security_logs_day SET SERDEPROPERTIES ("timestamp.formats"="yyyy-MM-dd HH:mm:ss.SSS");

INSERT OVERWRITE TABLE orangex_${ENVIRONMENT}.security_logs_day
PARTITION(day='$${hiveconf:security_date}')
SELECT
  -- t.fecha - INTERVAL '0.001' SECOND,
  date_format(t.fecha,'yyyy-MM-dd HH:mm:ss.SSS') fecha,
  date_format(t.prev_fecha,'yyyy-MM-dd HH:mm:ss.SSS'),
  t.client_id,
  t.site_id,
  t.real_source_address,
  t.real_source_port,
  t.source_translated_address,
  t.source_translated_port,
  t.destination_address,
  t.destination_port,
  t.prev_source,
  t.prev_real_port,
  t.prev_client,
  t.prev_site,
  t.transport_protocol
 FROM (
SELECT date_format(sas.fecha,'yyyy-MM-dd HH:mm:ss.SSS') fecha,sas.real_source_address,sas.source_translated_address,sas.source_translated_port,sas.client_id,sas.site_id,sas.destination_address,sas.destination_port,sas.real_source_port,sas.transport_protocol,
 LAG(sas.source_translated_port) OVER (PARTITION BY day(cast(sas.fecha as timestamp)) ORDER BY sas.source_translated_port,cast(sas.fecha as timestamp)) AS prev_state,
 LAG(sas.client_id) OVER (PARTITION BY day(cast(sas.fecha as timestamp)) ORDER BY sas.source_translated_port,cast(sas.fecha as timestamp)) AS prev_client,
 LAG(sas.real_source_address) OVER (PARTITION BY day(cast(sas.fecha as timestamp)) ORDER BY sas.source_translated_port,cast(sas.fecha as timestamp)) AS prev_source,
 LAG(cast(sas.fecha as timestamp)) OVER (PARTITION BY day(cast(sas.fecha as timestamp)) ORDER BY sas.source_translated_port,cast(sas.fecha as timestamp)) AS prev_fecha,
 LAG(sas.real_source_port) OVER (PARTITION BY day(cast(sas.fecha as timestamp)) ORDER BY sas.source_translated_port,cast(sas.fecha as timestamp)) AS prev_real_port,
 LAG(sas.site_id) OVER (PARTITION BY day(cast(sas.fecha as timestamp)) ORDER BY sas.source_translated_port,cast(sas.fecha as timestamp)) AS prev_site
 FROM  orangex_${ENVIRONMENT}.security_addresses sas
-- control choques:
left join orangex_${ENVIRONMENT}.security_temp dup on cast(sas.fecha as timestamp) = cast(sas.fecha as timestamp) and sas.source_translated_port||sas.transport_protocol =  dup.key
WHERE sas.source_translated_address IS NOT NULL
and sas.day = date('$${hiveconf:security_date}')
and sas.transport_protocol in ('6','17')
and dup.fecha is null
and dup.key is null
order by sas.client_id,sas.real_source_address,cast(fecha as timestamp)) t
 WHERE t.prev_state = t.source_translated_port
 and length (t.fecha) = 23
 and substr(t.fecha,1,10) rlike '[2]{1}[0-9]{3}-[0-9]{2}-[0-9]{2}$'
 --and t.real_source_address != t.prev_source
 UNION ALL
 select
 date_format(t.fecha,'yyyy-MM-dd HH:mm:ss.SSS') fecha,
 null as prev_fecha,
 t.client_id,
 t.site_id,
 t.real_source_address,
 t.real_source_port,
 t.source_translated_address,
 t.source_translated_port,
 t.destination_address,t.destination_port,
 '' as prev_source,
 '' as prev_real_port,
 '' as prev_client,
 '' as prev_site,
 t.transport_protocol
 from orangex_${ENVIRONMENT}.security_addresses t
 join
 (select source_translated_port, date_format(min(cast(fecha as timestamp)),'yyyy-MM-dd HH:mm:ss.SSS')fech
 FROM orangex_${ENVIRONMENT}.security_addresses
 where   day = date('$${hiveconf:security_date}')
 group by source_translated_port) min on min.source_translated_port = t.source_translated_port and cast(min.fech as timestamp) = cast(t.fecha as timestamp)
-- eliminando duplicados choques del insert
left join orangex_${ENVIRONMENT}.security_temp dup2 on t.fecha = dup2.fecha and t.source_translated_port||t.transport_protocol =  dup2.key
 where t.day = date('$${hiveconf:security_date}')
 and t.transport_protocol in ('6','17')
 and length (t.fecha) = 23
 and substr(t.fecha,1,10) rlike '[2]{1}[0-9]{3}-[0-9]{2}-[0-9]{2}$'
 and dup2.fecha is null
 and dup2.key is null;
-- UNION
-- select
-- CAST(date('$${hiveconf:security_date}')||' 23:59:59.999' AS TIMESTAMP),
-- T.FECHA,
-- t.client_id,
-- t.real_source_address,
-- t.real_source_port,
-- t.source_translated_address,
-- t.source_translated_port,
-- '-',
-- '-',
-- t.real_source_address as prev_source,
-- t.real_source_port as prev_real_port,
-- t.client_id as prev_client
-- from orangex_${ENVIRONMENT}.security_addresses t
-- join
-- (select source_translated_port, max(fecha)fech
-- FROM orangex_${ENVIRONMENT}.security_addresses
-- where   day = date('$${hiveconf:security_date}')
-- group by source_translated_port) max on max.source_translated_port = t.source_translated_port and max.fech = t.fecha
-- where t.day = date('$${hiveconf:security_date}');

-- MSCK REPAIR TABLE orangex_${ENVIRONMENT}.security_logs_day;
ALTER TABLE orangex_${ENVIRONMENT}.security_logs_day ADD IF NOT EXISTS PARTITION (day='$${hiveconf:security_date}');

-- DROP TABLE IF EXISTS `orangex_${ENVIRONMENT}.usage_xsecurity`;

 CREATE EXTERNAL TABLE IF NOT EXISTS `orangex_${ENVIRONMENT}.usage_xsecurity` (
    client_id   String
   ,site_id String
   ,client_name   String
   ,stats_day date
   ,total_outgoing int
   ,different_address int
   )
 PARTITIONED BY (day date)
 ROW FORMAT DELIMITED
 FIELDS TERMINATED BY ','
 LOCATION 's3://${BUCKET}/usage/xsecurity'
 TBLPROPERTIES ('serialization.null.format'='');

 insert overwrite table orangex_${ENVIRONMENT}.usage_xsecurity
 partition(day='$${hiveconf:security_date}')
 select
   t.client_id
  ,t.site_id
  ,s.name
  ,'$${hiveconf:security_date}'
  ,t.total
  ,t.distintas
 from orangex_${ENVIRONMENT}.sf_account s
 right join
 (select client_id,site_id,day,count(*)total,count(distinct destination_address||destination_port)distintas
  from orangex_${ENVIRONMENT}.security_logs_day l
  WHERE DAY = date('$${hiveconf:security_date}')
  group by client_id, site_id,day) t on s.id = t.client_id;

-- MSCK REPAIR TABLE orangex_${ENVIRONMENT}.usage_xsecurity;
ALTER TABLE orangex_${ENVIRONMENT}.usage_xsecurity ADD IF NOT EXISTS PARTITION (day='$${hiveconf:security_date}');

-- DROP TABLE IF EXISTS `orangex_${ENVIRONMENT}.alerts_xsecurity`;

CREATE EXTERNAL TABLE IF NOT EXISTS `orangex_${ENVIRONMENT}.alerts_xsecurity` (
    client_id   String
   ,site_id String
   ,client_name   String
   ,is_trial boolean
   ,stats_day date
   ,total_outgoing int
   ,activation_days int
   ,tipo_alerta String
   )
 PARTITIONED BY (day date)
 ROW FORMAT DELIMITED
 FIELDS TERMINATED BY ','
 LOCATION 's3://${BUCKET}/emr-logs/notifications/alerts_xsecurity'
 TBLPROPERTIES ('serialization.null.format'='');


insert overwrite table orangex_${ENVIRONMENT}.alerts_xsecurity
partition(day='$${hiveconf:security_date}')
select * from
  (
   select
   client_id,
   site_id,
   client_name,
   is_trial,
   date('$${hiveconf:security_date}'),
   sum(total_outgoing) suma,
   5,
   'NO USO TRIAL'
   from
     (
     select distinct
      us.client_id,
      us.site_id,
      us.client_name,
      cx.is_trial,
      stats_day,
      total_outgoing,
      datediff(stats_day,date(service_date))dias_activacion
      from  orangex_${ENVIRONMENT}.usage_xsecurity us
      join orangex_${ENVIRONMENT}.sf_account sa on sa.id = us.client_id
      join(
       select
       cif,
       is_trial,
       service_date
       from (
         select
         cif,
         is_trial,
         service_date,
         row_number() OVER (PARTITION BY cif ORDER BY is_trial desc) AS rank
         from orangex_${ENVIRONMENT}.cartera_xbo
         where process_date =  date('$${hiveconf:security_date}')
         and product_name like 'X Securit%'
         and asset_status = 'Activated')p
       where p.rank = 1)cx on sa.cif__c = cx.cif
      where  us.day <=  date('$${hiveconf:security_date}'))rn
   where dias_activacion between 0 and 5
   and is_trial
   group by client_id, site_id,client_name,is_trial)ac
 where suma < 300000
      UNION
       select
       us.client_id,
       us.site_id,
       us.client_name,
       false,
       us.day,
       total_outgoing,
       null,
       'USO PRODUCTO EN BAJA'
       from orangex_${ENVIRONMENT}.usage_xsecurity us
       join orangex_${ENVIRONMENT}.sf_account sa on sa.id = us.client_id
       join
       (select cif, date(max(deactivation_date)) fec_baja
        from orangex_${ENVIRONMENT}.cartera_xbo c1
          where process_date =  date('$${hiveconf:security_date}')
          and product_name like 'X Securit%'
          group by cif having count(case when asset_status = 'Activated' then 1 end) = 0)deac
        on deac.cif = sa.cif__c
        where  us.day =  date('$${hiveconf:security_date}')
        and us.day > deac.fec_baja;

-- MSCK REPAIR TABLE orangex_${ENVIRONMENT}.alerts_xsecurity;
ALTER TABLE orangex_${ENVIRONMENT}.alerts_xsecurity ADD IF NOT EXISTS PARTITION (day='$${hiveconf:security_date}');