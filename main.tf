# Data lookup to get our CIDR
data "aws_vpc" "default" {
    id = "${var.vpc_id}"
}

# The randomly generated database password
resource "random_string" "default" {
    length  = 12
    special = false
}

# DB Instance
resource "aws_db_instance" "default" {
    identifier                  = "${replace(var.name,"-","")}"
    username                    = "${local.username}"
    password                    = "${random_string.default.result}"
    port                        = "${local.port}"
    engine                      = "${var.engine}"
    engine_version              = "${local.engine_version}"
    instance_class              = "${var.instance_type}"
    allocated_storage           = "${var.allocated_storage}"
    storage_encrypted           = "${var.instance_type == "db.t2.micro" ? false : true}"
    vpc_security_group_ids      = ["${compact(concat(list(aws_security_group.default.id), var.security_group_ids))}"]
    db_subnet_group_name        = "${aws_db_subnet_group.default.name}"
    parameter_group_name        = "${aws_db_parameter_group.default.name}"
    multi_az                    = "${var.is_live ? true : false }"
    storage_type                = "gp2"
    publicly_accessible         = "false"
    snapshot_identifier         = "${var.restore_from_snapshot}"
    allow_major_version_upgrade = "${var.is_live ? true : false }"
    auto_minor_version_upgrade  = "${var.is_live ? true : false }"
    apply_immediately           = "false"
    maintenance_window          = "${var.maintenance_window}"
    skip_final_snapshot         = "${var.is_live ? false : true }"
    copy_tags_to_snapshot       = "true"
    backup_retention_period     = "${var.is_live ? 7 : 0 }"
    backup_window               = "${var.backup_window}"
    final_snapshot_identifier   = "${var.name}"

    tags                        = "${var.tags}"
}

# DB Parameter Groups
resource "aws_db_parameter_group" "default" {
    name      = "${var.name}"
    family    = "${local.engine_family}"
    parameter = "${var.db_parameter}"

    tags      = "${var.tags}"
}

# The DB subnet group
resource "aws_db_subnet_group" "default" {
    name       = "${var.name}"
    subnet_ids = ["${var.subnet_ids}"]

    tags       = "${var.tags}"
}

# A default security group we'll create to allow everyone in our CIDR access
resource "aws_security_group" "default" {
    name        = "${var.name}-rds-allow-cidr"
    description = "Allow inbound traffic from the CIDR"
    vpc_id      = "${var.vpc_id}"

    ingress {
        from_port   = "${local.port}"
        to_port     = "${local.port}"
        protocol    = "tcp"
        cidr_blocks = ["${data.aws_vpc.default.cidr_block}"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = "${merge(var.tags, map("Name", format("%s-rds-allow-cidr", var.name)))}"
}
