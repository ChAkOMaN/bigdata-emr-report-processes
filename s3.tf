data "aws_s3_bucket" "bucket" {
  bucket = "orange-x.smartlead-${var.ENVIRONMENT}"
}

resource "aws_s3_bucket_object" "trigger_fraude_send" {
  key    = "/shell_scripts/trigger_fraude_send.sh"
  bucket = "${data.aws_s3_bucket.bucket.bucket}"
  source = "scripts/trigger_fraude_send.sh"
  etag   = "${md5(file("scripts/trigger_fraude_send.sh"))}"

  tags {
    Name        = "trigger_fraude_send.sh"
    Deployed    = "terraform"
    Deployed_by = "${var.GITLAB_CI_PIPELINE_ID}"
    Repo        = "${var.GITLAB_CI_PROJECT_NAME}"
    Environment = "${var.ENVIRONMENT}"
  }
}

resource "aws_s3_bucket_object" "fraude_jar" {
  key    = "/spark_apps/report-fraude-process-assembly-1.0.1.jar"
  bucket = "${data.aws_s3_bucket.bucket.bucket}"
  source = "jars/report-fraude-process-assembly-1.0.1.jar"
  etag   = "${md5(file("jars/report-fraude-process-assembly-1.0.1.jar"))}"

  tags {
    Name        = "report-fraude-process-assembly-1.0.1.jar"
    Deployed    = "terraform"
    Deployed_by = "${var.GITLAB_CI_PIPELINE_ID}"
    Repo        = "${var.GITLAB_CI_PROJECT_NAME}"
    Environment = "${var.ENVIRONMENT}"
  }
}

resource "aws_s3_bucket_object" "trigger_apolo_send" {
  key    = "/shell_scripts/trigger_apolo_send.sh"
  bucket = "${data.aws_s3_bucket.bucket.bucket}"
  source = "scripts/trigger_apolo_send.sh"
  etag   = "${md5(file("scripts/trigger_apolo_send.sh"))}"

  tags {
    Name        = "trigger_apolo_send.sh"
    Deployed    = "terraform"
    Deployed_by = "${var.GITLAB_CI_PIPELINE_ID}"
    Repo        = "${var.GITLAB_CI_PROJECT_NAME}"
    Environment = "${var.ENVIRONMENT}"
  }
}

resource "aws_s3_bucket_object" "trigger_cnmc_send" {
  key    = "/shell_scripts/trigger_cnmc_send.sh"
  bucket = "${data.aws_s3_bucket.bucket.bucket}"
  source = "scripts/trigger_cnmc_send.sh"
  etag   = "${md5(file("scripts/trigger_cnmc_send.sh"))}"

  tags {
    Name        = "trigger_cnmc_send.sh"
    Deployed    = "terraform"
    Deployed_by = "${var.GITLAB_CI_PIPELINE_ID}"
    Repo        = "${var.GITLAB_CI_PROJECT_NAME}"
    Environment = "${var.ENVIRONMENT}"
  }
}

resource "aws_s3_bucket_object" "init_apolo_xsecurity" {
  key    = "/shell_scripts/init_apolo_xsecurity.sh"
  bucket = "${data.aws_s3_bucket.bucket.bucket}"
  source = "scripts/init_apolo_xsecurity.sh"
  etag   = "${md5(file("scripts/init_apolo_xsecurity.sh"))}"

  tags {
    Name        = "init_apolo_xsecurity.sh"
    Deployed    = "terraform"
    Deployed_by = "${var.GITLAB_CI_PIPELINE_ID}"
    Repo        = "${var.GITLAB_CI_PROJECT_NAME}"
    Environment = "${var.ENVIRONMENT}"
  }
}

resource "aws_s3_bucket_object" "init_apolo_addresses" {
  key    = "/shell_scripts/init_apolo_addresses.sh"
  bucket = "${data.aws_s3_bucket.bucket.bucket}"
  source = "scripts/init_apolo_addresses.sh"
  etag   = "${md5(file("scripts/init_apolo_addresses.sh"))}"

  tags {
    Name        = "init_apolo_addresses.sh"
    Deployed    = "terraform"
    Deployed_by = "${var.GITLAB_CI_PIPELINE_ID}"
    Repo        = "${var.GITLAB_CI_PROJECT_NAME}"
    Environment = "${var.ENVIRONMENT}"
  }
}

resource "aws_s3_bucket_object" "apolo_jar" {
  key    = "/spark_apps/report-apolo-process-assembly-1.0.1.jar"
  bucket = "${data.aws_s3_bucket.bucket.bucket}"
  source = "jars/report-apolo-process-assembly-1.0.1.jar"
  etag   = "${md5(file("jars/report-apolo-process-assembly-1.0.1.jar"))}"

  tags {
    Name        = "report-apolo-process-assembly-1.0.1.jar"
    Deployed    = "terraform"
    Deployed_by = "${var.GITLAB_CI_PIPELINE_ID}"
    Repo        = "${var.GITLAB_CI_PROJECT_NAME}"
    Environment = "${var.ENVIRONMENT}"
  }
}

resource "aws_s3_bucket_object" "cnmc_jar" {
  key    = "/spark_apps/report-cnmc-process-assembly-1.0.1.jar"
  bucket = "${data.aws_s3_bucket.bucket.bucket}"
  source = "jars/report-cnmc-process-assembly-1.0.1.jar"
  etag   = "${md5(file("jars/report-cnmc-process-assembly-1.0.1.jar"))}"

  tags {
    Name        = "report-cnmc-process-assembly-1.0.1.jar"
    Deployed    = "terraform"
    Deployed_by = "${var.GITLAB_CI_PIPELINE_ID}"
    Repo        = "${var.GITLAB_CI_PROJECT_NAME}"
    Environment = "${var.ENVIRONMENT}"
  }
}

data "template_file" "init_report" {
  template = "${file("templates/init_report.hql.tpl")}"

  vars {
    BUCKET      = "${data.aws_s3_bucket.bucket.bucket}"
    ENVIRONMENT = "${var.ENVIRONMENT}"
  }
}

resource "aws_s3_bucket_object" "init" {
  key     = "/hive_scripts/init_report.hql"
  bucket  = "${data.aws_s3_bucket.bucket.bucket}"
  content = "${data.template_file.init_report.rendered}"
  etag    = "${md5(file("templates/init_report.hql.tpl"))}"

  tags {
    Name        = "init_report.hql"
    Deployed    = "terraform"
    Deployed_by = "${var.GITLAB_CI_PIPELINE_ID}"
    Repo        = "${var.GITLAB_CI_PROJECT_NAME}"
    Environment = "${var.ENVIRONMENT}"
  }
}

data "template_file" "apolo_xsecurity" {
  template = "${file("templates/apolo_xsecurity.hql.tpl")}"

  vars {
    BUCKET      = "${data.aws_s3_bucket.bucket.bucket}"
    ENVIRONMENT = "${var.ENVIRONMENT}"
  }
}

resource "aws_s3_bucket_object" "asecurity" {
  key     = "/hive_scripts/apolo_xsecurity.hql"
  bucket  = "${data.aws_s3_bucket.bucket.bucket}"
  content = "${data.template_file.apolo_xsecurity.rendered}"
  etag    = "${md5(file("templates/apolo_xsecurity.hql.tpl"))}"

  tags {
    Name        = "apolo_xsecurity.hql"
    Deployed    = "terraform"
    Deployed_by = "${var.GITLAB_CI_PIPELINE_ID}"
    Repo        = "${var.GITLAB_CI_PROJECT_NAME}"
    Environment = "${var.ENVIRONMENT}"
  }
}


data "template_file" "apolo_address" {
  template = "${file("templates/apolo_address.hql.tpl")}"

  vars {
    BUCKET      = "${data.aws_s3_bucket.bucket.bucket}"
    ENVIRONMENT = "${var.ENVIRONMENT}"
  }
}

resource "aws_s3_bucket_object" "aaddress" {
  key     = "/hive_scripts/apolo_address.hql"
  bucket  = "${data.aws_s3_bucket.bucket.bucket}"
  content = "${data.template_file.apolo_address.rendered}"
  etag    = "${md5(file("templates/apolo_address.hql.tpl"))}"

  tags {
    Name        = "apolo_address.hql"
    Deployed    = "terraform"
    Deployed_by = "${var.GITLAB_CI_PIPELINE_ID}"
    Repo        = "${var.GITLAB_CI_PROJECT_NAME}"
    Environment = "${var.ENVIRONMENT}"
  }
}
data "template_file" "cleaning_json_pro_sh_tpl" {
  template = "${file("templates/cleaning_json_pro.sh.tpl")}"

  vars {
    BUCKET      = "${data.aws_s3_bucket.bucket.bucket}"
    ENVIRONMENT = "${var.ENVIRONMENT}"
  }
}

resource "aws_s3_bucket_object" "cleaning_json_pro_sh" {
  key     = "/shell_scripts/cleaning_json_pro.sh"
  bucket  = "${data.aws_s3_bucket.bucket.bucket}"
  content = "${data.template_file.cleaning_json_pro_sh_tpl.rendered}"
  etag    = "${md5(file("templates/cleaning_json_pro.sh.tpl"))}"

  tags {
    Name        = "cleaning_json_pro.sh"
    Deployed    = "terraform"
    Deployed_by = "${var.GITLAB_CI_PIPELINE_ID}"
    Repo        = "${var.GITLAB_CI_PROJECT_NAME}"
    Environment = "${var.ENVIRONMENT}"
  }
}

resource "aws_s3_bucket_object" "parser_security_jar" {
  key    = "/spark_apps/parser_security-assembly-1.0.1.jar"
  bucket = "${data.aws_s3_bucket.bucket.bucket}"
  source = "jars/parser_security-assembly-1.0.1.jar"
  etag   = "${md5(file("jars/parser_security-assembly-1.0.1.jar"))}"

  tags {
    Name        = "parser_security-assembly-1.0.1.jar"
    Deployed    = "terraform"
    Deployed_by = "${var.GITLAB_CI_PIPELINE_ID}"
    Repo        = "${var.GITLAB_CI_PROJECT_NAME}"
    Environment = "${var.ENVIRONMENT}"
  }
}

data "template_file" "security_logs_day_hql_tpl" {
  template = "${file("templates/security_logs_day.hql.tpl")}"

  vars {
    BUCKET      = "${data.aws_s3_bucket.bucket.bucket}"
    ENVIRONMENT = "${var.ENVIRONMENT}"
  }
}

resource "aws_s3_bucket_object" "security_logs_day_hql" {
  key     = "/hive_scripts/security_logs_day.hql"
  bucket  = "${data.aws_s3_bucket.bucket.bucket}"
  content = "${data.template_file.security_logs_day_hql_tpl.rendered}"
  etag    = "${md5(file("templates/security_logs_day.hql.tpl"))}"

  tags {
    Name        = "security_logs_day.hql"
    Deployed    = "terraform"
    Deployed_by = "${var.GITLAB_CI_PIPELINE_ID}"
    Repo        = "${var.GITLAB_CI_PROJECT_NAME}"
    Environment = "${var.ENVIRONMENT}"
  }
}

data "template_file" "security_logs_day_sh_tpl" {
  template = "${file("templates/security_logs_day.sh.tpl")}"

  vars {
    BUCKET      = "${data.aws_s3_bucket.bucket.bucket}"
    ENVIRONMENT = "${var.ENVIRONMENT}"
  }
}

resource "aws_s3_bucket_object" "security_logs_day_sh" {
  key     = "/shell_scripts/security_logs_day.sh"
  bucket  = "${data.aws_s3_bucket.bucket.bucket}"
  content = "${data.template_file.security_logs_day_sh_tpl.rendered}"
  etag    = "${md5(file("templates/security_logs_day.sh.tpl"))}"

  tags {
    Name        = "security_logs_day.sh"
    Deployed    = "terraform"
    Deployed_by = "${var.GITLAB_CI_PIPELINE_ID}"
    Repo        = "${var.GITLAB_CI_PROJECT_NAME}"
    Environment = "${var.ENVIRONMENT}"
  }
}
