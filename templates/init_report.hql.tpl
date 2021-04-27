DROP TABLE IF EXISTS `orangex_${ENVIRONMENT}.report_fraude_clientes`;
DROP TABLE IF EXISTS `orangex_${ENVIRONMENT}.report_fraude_lineas`;

DROP TABLE IF EXISTS `orangex_${ENVIRONMENT}.report_apolo_clientes`;
DROP TABLE IF EXISTS `orangex_${ENVIRONMENT}.report_apolo_lineas`;
DROP TABLE IF EXISTS `orangex_${ENVIRONMENT}.report_apolo_clientes_add`;
DROP TABLE IF EXISTS `orangex_${ENVIRONMENT}.report_apolo_lineas_add`;
DROP TABLE IF EXISTS `orangex_${ENVIRONMENT}.report_apolo_xsecurity`;

DROP TABLE IF EXISTS `orangex_${ENVIRONMENT}.report_cnmc_lineas`;

CREATE EXTERNAL TABLE IF NOT EXISTS `orangex_${ENVIRONMENT}.report_fraude_clientes` (
  ClientId string
  ,CIF_NIF string
  ,TipoDocumento string
  ,Pais string
  ,Nacionalidad string
  ,FechaNac string 
  ,Ciudad string
  ,Provincia string
  ,CP string
  ,TipoVia string
  ,DireccionCompleta string
  ,NombreCompleto string
  ,PlanPrecios string
  ,Segmento string
  ,TarjCredito string
  ,TelefonoContacto string
  ,CuentaFacturacion string
  ,CicloFacturacion string
  ,Estado string
  ,FECHA_ACTIVACION string
  ,FECHA_DESACTIVACION string
  ,FECHA_SUSPENSION string
  ,FECHA_REACTIVACION string
  ,OMVcode string)
PARTITIONED BY (day string)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|'
LOCATION 's3://${BUCKET}/reports/fraude_clientes'
TBLPROPERTIES ('serialization.null.format'='');

MSCK REPAIR TABLE orangex_${ENVIRONMENT}.report_fraude_clientes;

CREATE EXTERNAL TABLE orangex_${ENVIRONMENT}.report_fraude_lineas (
`MSISDN` string,
`IMSI` string,
`PRICEPLAN` string,
`IMEI` string,  
`OMVcode` string,
`FechaEstado` string,
`MigrationType` string,
`BillingDay` string,
`Estado` string,
`ClientId` string,
`Segmento` string,
`FechaModificacionImpagos` string,
`ImporteDeuda` string,
`NumeroImpagos` string,
`SFID` string,
`Pais` string,
`Nacionalidad` string,
`FechaNacimiento` string,
`CIF_NIF` string,
`Provincia` string,
`CodigoPostal` string,
`NumeroCuentaBancaria` string,
`TarjCredito` string,
`Servicios` string,
`Suspensiones` string,
`FechaDeActivacion` string,
`MarketingCode` string)
PARTITIONED BY (`day` string)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|'
LOCATION 's3://${BUCKET}/reports/fraude_lineas'
TBLPROPERTIES ('serialization.null.format'='');

MSCK REPAIR TABLE orangex_${ENVIRONMENT}.report_fraude_lineas;

CREATE EXTERNAL TABLE IF NOT EXISTS `orangex_${ENVIRONMENT}.report_apolo_clientes` (
  ID_CLIENTE string
  ,TIPO_CLIENTE string
  ,ESTADO_CLIENTE string
  ,TIPO_DOCUMENTO string
  ,NUM_DOCUMENTO string
  ,NOMBRE_CLIENTE string 
  ,RAZON_SOCIAL string
  ,FECHA_ALTA string
  ,FECHA_ACTIVACION_CLIENTE string
  ,FECHA_ESTADO_CLIENTE string
  ,DIRECCION_PRINCIPAL_COMPLETA string
  ,TIPO_VIA_DIRECCION_PRINCIPAL string
  ,CALLE_DIRECCION_PRINCIPAL string
  ,NUMERO_DIRECCION_PRINCIPAL string
  ,ESCALERA_DIRECCION_PRINCIPAL string
  ,PISO_DIRECCION_PRINCIPAL string
  ,PUERTA_DIRECCION_PRINCIPAL string
  ,CODIGO_POSTAL_DIRECCION_PRINCIPAL string
  ,MUNICIPIO_DIRECCION_PRINCIPAL string
  ,PROVINCIA_DIRECCION_PRINCIPAL string
  ,PAIS_DIRECCION_PRINCIPAL string
  ,SISTEMA string
)
PARTITIONED BY (day string)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|'
LOCATION
  's3://${BUCKET}/reports/apolo_clientes'
TBLPROPERTIES ('serialization.null.format'='');

MSCK REPAIR TABLE orangex_${ENVIRONMENT}.report_apolo_clientes;

CREATE EXTERNAL TABLE IF NOT EXISTS `orangex_${ENVIRONMENT}.report_apolo_clientes_add` (
  ID_CLIENTE string
  ,TIPO_CLIENTE string
  ,ESTADO_CLIENTE string
  ,TIPO_DOCUMENTO string
  ,NUM_DOCUMENTO string
  ,NOMBRE_CLIENTE string 
  ,RAZON_SOCIAL string
  ,FECHA_ALTA string
  ,FECHA_ACTIVACION_CLIENTE string
  ,FECHA_ESTADO_CLIENTE string
  ,DIRECCION_PRINCIPAL_COMPLETA string
  ,TIPO_VIA_DIRECCION_PRINCIPAL string
  ,CALLE_DIRECCION_PRINCIPAL string
  ,NUMERO_DIRECCION_PRINCIPAL string
  ,ESCALERA_DIRECCION_PRINCIPAL string
  ,PISO_DIRECCION_PRINCIPAL string
  ,PUERTA_DIRECCION_PRINCIPAL string
  ,CODIGO_POSTAL_DIRECCION_PRINCIPAL string
  ,MUNICIPIO_DIRECCION_PRINCIPAL string
  ,PROVINCIA_DIRECCION_PRINCIPAL string
  ,PAIS_DIRECCION_PRINCIPAL string
  ,SISTEMA string
)
PARTITIONED BY (day string)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|'
LOCATION
  's3://${BUCKET}/reports/apolo_clientes_add'
TBLPROPERTIES ('serialization.null.format'='');

MSCK REPAIR TABLE orangex_${ENVIRONMENT}.report_apolo_clientes_add;

CREATE EXTERNAL TABLE orangex_${ENVIRONMENT}.report_apolo_lineas (
`ID_SERVICIO` string,
`ID_CLIENTE` string,
`ID_TIPO_SERVICIO` string,
`TIPO_SERVICIO` string,  
`ID_CONTRATO` string,
`NUMERO_TELEFONO` string,
`FECHA_ALTA_SERVICIO` string,
`FECHA_ACTIVACION_SERVICIO` string,
`FECHA_DESACTIVACION_SERVICIO` string,
`ESTADO_SERVICIO` string,
`IMSI` string,
`ICCID` string,
`IMEI` string,
`PUK` string,
`MARCA_TERMINAL` string,
`MODELO_TERMINAL` string,
`NUMERO_DE_SERIE_TERMINAL` string,
`IP_CONEXION` string,
`LOGIN_CONEXION` string,
`DIRECCION_INSTALACION_COMPLETA` string,
`TIPO_VIA_DIRECCION_INSTALACION` string,
`CALLE_DIRECCION_INSTALACION` string,
`NUMERO_DIRECCION_INSTALACION` string,
`ESCALERA_DIRECCION_INSTALACION` string,
`PISO_DIRECCION_INSTALACION` string,
`PUERTA_DIRECCION_INSTALACION` string,
`CODIGO_POSTAL_DIRECCION_INSTALACION` string,
`MUNICIPIO_DIRECCION_INSTALACION` string,
`PROVINCIA_DIRECCION_INSTALACION` string,
`PAIS_DIRECCION_INSTALACION` string,
`TIPO_VIA_DIRECCION_FACTURACION` string,
`CALLE_DIRECCION_FACTURACION` string,
`NUMERO_DIRECCION_FACTURACION` string,
`ESCALERA_DIRECCION_FACTURACION` string,
`PISO_DIRECCION_FACTURACION` string,
`PUERTA_DIRECCION_FACTURACION` string,
`CODIGO_POSTAL_DIRECCION_FACTURACION` string,
`MUNICIPIO_DIRECCION_FACTURACION` string,
`PROVINCIA_DIRECCION_FACTURACION` string,
`PAIS_DIRECCION_FACTURACION` string,  
`FECHA_ESTADO` string,
`NOMBRE_TITULAR_CUENTA_BANCARIA` string,
`NOMBRE_TITULAR_LINEA` string,
`DNI_TITULAR_LINEA` string,
`SISTEMA` string)
PARTITIONED BY ( 
  `day` string)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|'
LOCATION 
  's3://${BUCKET}/reports/apolo_lineas'
TBLPROPERTIES ('serialization.null.format'='');

MSCK REPAIR TABLE orangex_${ENVIRONMENT}.report_apolo_lineas;

CREATE EXTERNAL TABLE orangex_${ENVIRONMENT}.report_apolo_lineas_add (
`ID_SERVICIO` string,
`ID_CLIENTE` string,
`ID_TIPO_SERVICIO` string,
`TIPO_SERVICIO` string,  
`ID_CONTRATO` string,
`NUMERO_TELEFONO` string,
`FECHA_ALTA_SERVICIO` string,
`FECHA_ACTIVACION_SERVICIO` string,
`FECHA_DESACTIVACION_SERVICIO` string,
`ESTADO_SERVICIO` string,
`IMSI` string,
`ICCID` string,
`IMEI` string,
`PUK` string,
`MARCA_TERMINAL` string,
`MODELO_TERMINAL` string,
`NUMERO_DE_SERIE_TERMINAL` string,
`IP_CONEXION` string,
`LOGIN_CONEXION` string,
`DIRECCION_INSTALACION_COMPLETA` string,
`TIPO_VIA_DIRECCION_INSTALACION` string,
`CALLE_DIRECCION_INSTALACION` string,
`NUMERO_DIRECCION_INSTALACION` string,
`ESCALERA_DIRECCION_INSTALACION` string,
`PISO_DIRECCION_INSTALACION` string,
`PUERTA_DIRECCION_INSTALACION` string,
`CODIGO_POSTAL_DIRECCION_INSTALACION` string,
`MUNICIPIO_DIRECCION_INSTALACION` string,
`PROVINCIA_DIRECCION_INSTALACION` string,
`PAIS_DIRECCION_INSTALACION` string,
`TIPO_VIA_DIRECCION_FACTURACION` string,
`CALLE_DIRECCION_FACTURACION` string,
`NUMERO_DIRECCION_FACTURACION` string,
`ESCALERA_DIRECCION_FACTURACION` string,
`PISO_DIRECCION_FACTURACION` string,
`PUERTA_DIRECCION_FACTURACION` string,
`CODIGO_POSTAL_DIRECCION_FACTURACION` string,
`MUNICIPIO_DIRECCION_FACTURACION` string,
`PROVINCIA_DIRECCION_FACTURACION` string,
`PAIS_DIRECCION_FACTURACION` string,  
`FECHA_ESTADO` string,
`NOMBRE_TITULAR_CUENTA_BANCARIA` string,
`NOMBRE_TITULAR_LINEA` string,
`DNI_TITULAR_LINEA` string,
`SISTEMA` string)
PARTITIONED BY ( 
  `day` string)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|'
LOCATION 
  's3://${BUCKET}/reports/apolo_lineas_add'
TBLPROPERTIES ('serialization.null.format'='');

MSCK REPAIR TABLE orangex_${ENVIRONMENT}.report_apolo_lineas_add;

CREATE EXTERNAL TABLE orangex_${ENVIRONMENT}.report_cnmc_lineas (
`EstadoLinea` string,
`INST_PROC_ID` string,
`MSISDN` string,
`NombreTitular` string,
`RazonSocialTitular` string,
`CIF` string,
`Direccion1` string,
`Direccion2` string,
`Poblacion` string,
`Provincia` string,
`CodigoPostal` string,
`ConsentimientoGUIA` string,
`ConsentimientoVenta` string,
`ModoPago` string,
`RazonSocialOperador` string,
`CIFOperador` string
)
PARTITIONED BY ( 
  `day` string)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|'
LOCATION 
  's3://${BUCKET}/reports/cnmc_lineas'
TBLPROPERTIES ('serialization.null.format'='');

MSCK REPAIR TABLE orangex_${ENVIRONMENT}.report_cnmc_lineas;

--------------------------X-SECURITY---------------------------------

DROP TABLE IF EXISTS `orangex_${ENVIRONMENT}.security_addresses`;

CREATE EXTERNAL TABLE IF NOT EXISTS `orangex_${ENVIRONMENT}.security_addresses` (
   client_id   String
  ,site_id   String
  ,real_source_address string
  ,real_source_port string
  ,source_translated_address string
  ,source_translated_port string
  ,destination_address string
  ,destination_port string
  ,fecha string
  ,transport_protocol string
  )
PARTITIONED BY (day date)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
LOCATION 's3://${BUCKET}/cef_logs_cleaned'
TBLPROPERTIES ('serialization.null.format'='');

MSCK REPAIR TABLE orangex_${ENVIRONMENT}.security_addresses;

CREATE EXTERNAL TABLE orangex_${ENVIRONMENT}.report_apolo_xsecurity (
`Id_Tipo_Servicio_Uso` string,
`Tipo_Servicio_Uso` string,
`fecha_evento_start` string,
`duracion` int,
`fecha_evento_stop` string,
`Direccion_IPv4_Origen` string,
`Puerto_Origen` string,
`transport_protocol` string,
`Direccion_IPv6_Origen_Ini` string,
`Direccion_IPv6_Origen_Fin` string,
`Id_Cliente` string,
`Id_Servicio` string
)
PARTITIONED BY ( 
  `day` string)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '|'
STORED AS TEXTFILE
LOCATION 
  's3://${BUCKET}/reports/apolo_xsecurity'
TBLPROPERTIES ('serialization.null.format'='');

MSCK REPAIR TABLE orangex_${ENVIRONMENT}.report_apolo_xsecurity;