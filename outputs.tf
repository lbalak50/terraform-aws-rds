output "instance_id" {
    description = "The instance_id of the RDS instance"
    value = "${aws_db_instance.default.id}"
}

output "address" {
    description = "The address to reach this database instance"
    value = "${aws_db_instance.default.address}"
}

output "port" {
    description = "The port of this instance"
    value = "${local.port}"
}

output "username" {
    description = "The username to log into this database as a superuser"
    value = "${local.username}"
}

output "database_password" {
    description = "The randomly generated password for this database super admin"
    value = "${random_string.default.result}"
}
