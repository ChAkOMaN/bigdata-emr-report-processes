data "aws_vpc" "vpc-bigdata" {
  state   = "available"
  default = false

  tags {
    Name        = "vpc-bigdata"
    Created     = "terraform"
    Environment = "${var.VPC_ENVIRONMENT}"
  }
}

data "aws_subnet_ids" "db_subnets_id_private" {
  vpc_id = "${data.aws_vpc.vpc-bigdata.id}"

  tags = {
    Type = "private"
  }
}

data "aws_subnet" "db_subnet_private" {
  count = "${length(data.aws_subnet_ids.db_subnets_id_private.ids)}"
  id    = "${data.aws_subnet_ids.db_subnets_id_private.ids[count.index]}"
}

data "aws_security_group" "emr_bd" {
  name   = "emr-bd"
  vpc_id = "${data.aws_vpc.vpc-bigdata.id}"

  tags = {
    Name        = "emr-bd"
    Environment = "${var.SG_ENVIRONMENT}"
    Deployed    = "Terraform"
  }
}

data "aws_security_group" "emr_service" {
  tags = {
    Name        = "emr-service-${var.SG_ENVIRONMENT}"
    Environment = "${var.SG_ENVIRONMENT}"
    Deployed    = "Terraform"
  }
}

data "aws_ami" "emr_custom_ami" {
  most_recent = true
  owners      = ["${var.AMI_OWNER}"]

  filter {
    name   = "tag:Product"
    values = ["EMR"]
  }

  filter {
    name   = "tag:AMI_Version"
    values = ["0.0.3"]
  }

  filter {
    name   = "name"
    values = ["EMR - bigdata -*"]
  }
}

data "aws_iam_role" "iam_emr_service_role" {
  name = "iam_emr_service_role_${var.ENVIRONMENT}"
}

data "aws_iam_instance_profile" "emr_profile" {
  name = "emr_profile_${var.ENVIRONMENT}"
}

resource "aws_emr_cluster" "emr_cluster" {
  name          = "EMR-${var.ENVIRONMENT}-bigdata-report-auto"
  release_label = "emr-5.27.0"
  applications  = ["Hadoop", "Spark", "Hive"]

  termination_protection            = false
  keep_job_flow_alive_when_no_steps = false

  custom_ami_id = "${data.aws_ami.emr_custom_ami.id}"

  log_uri = "s3://orange-x.smartlead-${var.ENVIRONMENT}/emr-logs/EMR-${var.ENVIRONMENT}-bigdata-report/"

  ec2_attributes {
    subnet_id                         = "${data.aws_subnet.db_subnet_private.0.id}"
    emr_managed_master_security_group = "${data.aws_security_group.emr_bd.id}"
    emr_managed_slave_security_group  = "${data.aws_security_group.emr_bd.id}"
    service_access_security_group     = "${data.aws_security_group.emr_service.id}"
    instance_profile                  = "${data.aws_iam_instance_profile.emr_profile.arn}"
  }

  master_instance_group {
    instance_type  = "${var.EMR_MASTER_INSTANCE}"
    instance_count = 1
    bid_price = "${var.SPOT_PRICE}"
  }

  core_instance_group {
    instance_type  = "${var.EMR_WORKER_INSTANCE}"
    instance_count = "${var.EMR_NUM_WORKERS}"
    bid_price = "${var.SPOT_PRICE}"
  }

  bootstrap_action {
    path = "s3://orange-x.smartlead-${var.ENVIRONMENT}/bootstrap/import_spark_infra.sh"
    name = "Import Spark Infra"
  }

  step {
    name              = "Init Reports"
    action_on_failure = "TERMINATE_CLUSTER"

    hadoop_jar_step {
      jar  = "command-runner.jar"
      args = ["hive-script", "--run-hive-script", "--args", "-f", "s3://orange-x.smartlead-${var.ENVIRONMENT}/hive_scripts/init_report.hql"]
    }
  }

  step {
    name              = "Fraude Report"
    action_on_failure = "CONTINUE"

    hadoop_jar_step {
      jar  = "command-runner.jar"
      args = ["spark-submit", "--deploy-mode", "cluster", "--class", "com.orange_x.ReportFraude", "--master", "yarn", "--files", "/home/hadoop/app.conf", "s3://orange-x.smartlead-${var.ENVIRONMENT}/spark_apps/report-fraude-process-assembly-1.0.1.jar"]
    }
  }

  step {
    name              = "Fraude Send"
    action_on_failure = "CONTINUE"

    hadoop_jar_step {
      jar  = "command-runner.jar"
      args = ["bash", "-c", "export ENVIRONMENT=${var.ENVIRONMENT}; aws s3 cp s3://orange-x.smartlead-${var.ENVIRONMENT}/shell_scripts/trigger_fraude_send.sh .;chmod +x trigger_fraude_send.sh; ./trigger_fraude_send.sh"]
    }
  }

  step {
    name              = "CNMC Report"
    action_on_failure = "CONTINUE"

    hadoop_jar_step {
      jar  = "command-runner.jar"
      args = ["spark-submit", "--deploy-mode", "cluster", "--class", "com.orange_x.ReportCnmc", "--master", "yarn", "--files", "/home/hadoop/app.conf", "s3://orange-x.smartlead-${var.ENVIRONMENT}/spark_apps/report-cnmc-process-assembly-1.0.1.jar"]
    }
  }

  step {
    name              = "CNMC Send"
    action_on_failure = "CONTINUE"

    hadoop_jar_step {
      jar  = "command-runner.jar"
      args = ["bash", "-c", "export ENVIRONMENT=${var.ENVIRONMENT}; aws s3 cp s3://orange-x.smartlead-${var.ENVIRONMENT}/shell_scripts/trigger_cnmc_send.sh .;chmod +x trigger_cnmc_send.sh; ./trigger_cnmc_send.sh"]
    }
  }

  step {
    name              = "Apolo Report"
    action_on_failure = "TERMINATE_CLUSTER"

    hadoop_jar_step {
      jar  = "command-runner.jar"
      args = ["spark-submit", "--deploy-mode", "cluster", "--class", "com.orange_x.ReportApolo", "--master", "yarn", "--files", "/home/hadoop/app.conf", "s3://orange-x.smartlead-${var.ENVIRONMENT}/spark_apps/report-apolo-process-assembly-1.0.1.jar","${var.APOLO_DATE}"]
    }
  }

  step {
    name              = "Apolo Addresses"
    action_on_failure = "TERMINATE_CLUSTER"

    hadoop_jar_step {
      jar  = "command-runner.jar"
      args = ["bash", "-c", "export ENVIRONMENT=${var.ENVIRONMENT};export AP_ADDRESS_DATE=${var.AP_ADDRESS_DATE};aws s3 cp s3://orange-x.smartlead-${var.ENVIRONMENT}/shell_scripts/init_apolo_addresses.sh .;chmod +x init_apolo_addresses.sh; ./init_apolo_addresses.sh"]
    }
  }

  step {
    name              = "Parser Cybersecurity"
    action_on_failure = "CONTINUE"

    hadoop_jar_step {
      jar  = "command-runner.jar"
      args = ["spark-submit", "--deploy-mode", "cluster", "--class", "com.orange_x.ParserCybersecurity", "--master", "yarn", "--files", "/home/hadoop/app.conf", "s3://orange-x.smartlead-${var.ENVIRONMENT}/spark_apps/parser_security-assembly-1.0.1.jar", "${var.SECURITY_DATE}", "${var.DATE_FROM}", "${var.DATE_TO}"]
    }
  }

  step {
    name              = "Logs Cybersecurity"
    action_on_failure = "TERMINATE_CLUSTER"

    hadoop_jar_step {
      jar  = "command-runner.jar"
      args = ["bash", "-c", "export SECURITY_DATE=${var.SECURITY_DATE};export DATE_FROM=${var.DATE_FROM};aws s3 cp s3://orange-x.smartlead-${var.ENVIRONMENT}/shell_scripts/security_logs_day.sh .;chmod +x security_logs_day.sh; ./security_logs_day.sh"]
    }
  }

  step {
    name              = "Apolo XSecurity"
    action_on_failure = "TERMINATE_CLUSTER"

    hadoop_jar_step {
      jar  = "command-runner.jar"
      args = ["bash", "-c", "export ENVIRONMENT=${var.ENVIRONMENT};export SECURITY_DATE=${var.SECURITY_DATE};aws s3 cp s3://orange-x.smartlead-${var.ENVIRONMENT}/shell_scripts/init_apolo_xsecurity.sh .;chmod +x init_apolo_xsecurity.sh; ./init_apolo_xsecurity.sh"]
    }
  }

  step {
    name              = "Apolo Send"
    action_on_failure = "TERMINATE_CLUSTER"

    hadoop_jar_step {
      jar  = "command-runner.jar"
      args = ["bash", "-c", "export ENVIRONMENT=${var.ENVIRONMENT}; aws s3 cp s3://orange-x.smartlead-${var.ENVIRONMENT}/shell_scripts/trigger_apolo_send.sh .;chmod +x trigger_apolo_send.sh; ./trigger_apolo_send.sh"]
    }
  }

  configurations = "emr_configurations.json"
  service_role   = "${data.aws_iam_role.iam_emr_service_role.arn}"

  tags = {
    Environment = "${var.ENVIRONMENT}"
    Deployed    = "Terraform"
    Deployed_by = "gitlab-ci-${var.GITLAB_CI_PIPELINE_ID}"
    Repo        = "${var.GITLAB_CI_PROJECT_NAME}"
  }
}
