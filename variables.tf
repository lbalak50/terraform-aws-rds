###################
# Required Inputs #
###################
variable "name" {
    description = "Name of this resource"
}

variable "vpc_id" {
    description = "The ID of the VPC we want to place this RDS in"
}

variable "subnet_ids" {
    description = "The subnet(s) which this RDS will exist in, typically your public subnet ids"
    type    = "list"
}



###################
# Optional Inputs #
###################
variable "engine" {
    description = "RDS Engine, can be mysql, mariadb, postgres"  # later support aurora, mssql, oracle
    default     = "mysql"
}

# See: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.html
variable "instance_type" {
    description = "Instance type of RDS"
    default     = "db.t2.micro"
}

variable "allocated_storage" {
    description = "The allocated storage to this database in GBs"
    default     = "10"
}

variable "is_live" {
    description = "Is a live database, if true then this will be multi-az and have automated backups"
    default     = false
}

variable "tags" {
    description = "A map of tags to add to all resources"
    default     = {}
}

variable "security_group_ids" {
    description = "A list of extra security group ids to associate with this database"
    type    = "list"
    default = []
}



###################
# Tertiary Inputs #
###################
# WARNING: Only specify this if you know what you're doing, aka, you have a specific version requirement for your db instance
variable "engine_version" {
    description = "This will force-set the engine version.  This does NOT need to be specified, it will be auto-detected"
    default     = ""
}

variable "maintenance_window" {
    description = "The weekly window to perform maintenance in. Syntax: 'ddd:hh24:mi-ddd:hh24:mi' UTC eg: Sun:01:00-Sun:02:00"
    default     = "Sun:01:00-Sun:02:00"
}

variable "backup_window" {
    description = "The daily window in which this database performs database snapshots, can't overlap with maintenance window"
    default     = "23:00-01:00"
}

# Note: Changes here may require an instance restart
variable "db_parameter" {
    description = "These are engine-specific settings you can tweak.  This can be used to turn on stuff like slow logs, if desired"
    type    = "list"
    default = []
}

variable "restore_from_snapshot" {
    description = "If restoring from a snapshot, specify the name of the snapshot here"
    default     = ""
}



#######################
# Generated Variables #
#######################
# TODO: Make this support Oracle and Microsoft SQL Server upon demand
# TODO: Maybe make this support aurora also?  But aurora requires a different terraform resource (aws_rds_cluster) which we could optionally use via terraform count?
locals {
    username = "odsuperadmin"

    port_lookup = {
        mysql             = "3306"
        mariadb           = "3306"
        postgres          = "5432"
        // aurora            = "3306"
        // aurora-mysql      = "3306"
        // aurora-postgresql = "5432"
    }
    port = "${lookup(local.port_lookup, var.engine)}"

    # These are aws "defaults" recommended versions as of February 15, 2018
    engine_version_lookup = {
        mysql             = "5.6.37"
        mariadb           = "10.1.26"
        postgres          = "9.6.5"
        // aurora            = "5.6.10a"
        // aurora-mysql      = "5.7.12"
        // aurora-postgresql = "9.6.5"
    }
    engine_version = "${length(var.engine_version) > 0 ? var.engine_version : lookup(local.engine_version_lookup, var.engine)}"

    # This string is used to create the parameter group
    engine_family  = "${var.engine}${element(split(".",local.engine_version),0)}.${element(split(".",local.engine_version),1)}"

    # Currently unused, use if/when implementing Aurora support
    is_aurora      = "${contains(list("aurora", "aurora-mysql", "aurora-postgresql"), var.engine) ? true : false}"
}
