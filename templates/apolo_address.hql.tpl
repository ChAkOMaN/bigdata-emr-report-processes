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


insert overwrite table orangex_${ENVIRONMENT}.report_apolo_clientes_add
partition(day='$${hiveconf:ap_address_date}')
select distinct
ras.id_cliente
,ras.tipo_cliente
,ras.estado_cliente
,ras.tipo_documento
,ras.num_documento
,ras.nombre_cliente
,ras.razon_social
,ras.fecha_alta
,ras.FECHA_ACTIVACION_CLIENTE 
,ras.FECHA_ESTADO_CLIENTE 
 ,CONCAT(coalesce(sac.tipo_de_via__c ,ras.tipo_via_direccion_principal), ' ', coalesce(sac.nombre_de_la_via__c ,ras.calle_direccion_principal), ' ', 
 coalesce(sac.numero_de_la_via__c ,ras.numero_direccion_principal), ', ', coalesce(sac.complemento__c ,ras.piso_direccion_principal) , '; ', coalesce( sac.codigo_postal__c,ras.codigo_postal_direccion_principal), ' ',
  coalesce(sac.municipio__c ,ras.municipio_direccion_principal), ' (', coalesce(sac.state__c ,ras.provincia_direccion_principal), '); ', coalesce( sac.pais__c,ras.pais_direccion_principal)) AS DIRECCION_PRINCIPAL_COMPLETA
,coalesce(sac.tipo_de_via__c ,ras.tipo_via_direccion_principal) as tipo_via_direccion_principal
,coalesce(sac.nombre_de_la_via__c ,ras.calle_direccion_principal) as calle_direccion_principal
,coalesce(sac.numero_de_la_via__c ,ras.numero_direccion_principal) as numero_direccion_principal
,ras.escalera_direccion_principal
,coalesce(sac.complemento__c ,ras.piso_direccion_principal) as piso_direccion_principal
,ras.puerta_direccion_principal
,coalesce( sac.codigo_postal__c,ras.codigo_postal_direccion_principal) as codigo_postal_direccion_principal
,coalesce(sac.municipio__c ,ras.municipio_direccion_principal) as municipio_direccion_principal
,coalesce(sac.state__c ,ras.provincia_direccion_principal) as provincia_direccion_principal
,coalesce( sac.pais__c,ras.pais_direccion_principal) as pais_direccion_principal 
,ras.sistema
from orangex_${ENVIRONMENT}.sf_account sac 
join
(
  select ra.*,sa.headquarterid__c from orangex_${ENVIRONMENT}.sf_account sa
join orangex_${ENVIRONMENT}.report_apolo_clientes ra on sa.cif__c = ra.num_documento and day =date('$${hiveconf:ap_address_date}')
where (sa.headquarterid__c is not null and sa.headquarterid__c <> '')
  ) ras on ras.headquarterid__c = sac.id
  ;

insert overwrite table orangex_${ENVIRONMENT}.report_apolo_lineas_add
partition(day='$${hiveconf:ap_address_date}')
  select distinct
ras.id_servicio
,ras.id_cliente
,ras.id_tipo_servicio
,ras.tipo_servicio
,ras.id_contrato
,ras.numero_telefono
,ras.fecha_alta_servicio
,ras.fecha_activacion_servicio
,ras.fecha_desactivacion_servicio
,ras.estado_servicio
,ras.imsi
,ras.iccid
,ras.imei
,ras.puk
,ras.marca_terminal
,ras.modelo_terminal
,ras.numero_de_serie_terminal
,ras.ip_conexion
,ras.login_conexion
,ras.direccion_instalacion_completa
,ras.tipo_via_direccion_instalacion
,ras.calle_direccion_instalacion
,ras.numero_direccion_instalacion
,ras.escalera_direccion_instalacion
,ras.piso_direccion_instalacion
,ras.puerta_direccion_instalacion
,ras.codigo_postal_direccion_instalacion
,ras.municipio_direccion_instalacion
,ras.provincia_direccion_instalacion
,ras.pais_direccion_instalacion
,coalesce(sac.tipo_de_via__c ,ras.tipo_via_direccion_facturacion) as tipo_via_direccion_instalacion
,coalesce(sac.nombre_de_la_via__c ,ras.calle_direccion_facturacion) as calle_direccion_facturacion
,coalesce(sac.numero_de_la_via__c ,ras.numero_direccion_facturacion) as numero_direccion_facturacion
,ras.escalera_direccion_facturacion
,coalesce(sac.complemento__c ,ras.piso_direccion_facturacion) as piso_direccion_facturacion
,ras.puerta_direccion_facturacion
,coalesce( sac.codigo_postal__c,ras.codigo_postal_direccion_facturacion) as codigo_postal_direccion_facturacion
,coalesce(sac.municipio__c ,ras.municipio_direccion_facturacion) as municipio_direccion_facturacion
,coalesce(sac.state__c ,ras.provincia_direccion_facturacion) as provincia_direccion_facturacion
,coalesce( sac.pais__c,ras.pais_direccion_facturacion) as pais_direccion_facturacion 
,ras.fecha_estado
,ras.nombre_titular_cuenta_bancaria
,ras.nombre_titular_linea
,ras.dni_titular_linea
,ras.sistema
from orangex_${ENVIRONMENT}.sf_account sac 
join
(
  select ra.*,sa.billingid__c from orangex_${ENVIRONMENT}.sf_account sa
join orangex_${ENVIRONMENT}.report_apolo_lineas ra on sa.cif__c = ra.dni_titular_linea and day =date('$${hiveconf:ap_address_date}')
where (sa.headquarterid__c is not null and sa.headquarterid__c <> '')
  ) ras on ras.billingid__c = sac.id
  ;