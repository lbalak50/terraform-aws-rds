AWS RDS Terraform Module -
========================

This is the RDS-for-dummies module for AWS.  This module automatically creates a RDS instance and allows all traffic from the local subnet cidr so you can just access it immediately from your servers or Lambdas.

Usage
-----

```hcl
provider "aws" {
  version = "~> 1.0.0"
  region  = "eu-west-1"
}

# Add our RDS Database
module "mysql" {
    source             = "github.com/olindata/terraform-aws-ezvpc.git"
    name               = "widgetsrds"
    vpc_id             = "vpc-12312312"                          # Put your VPC ID here, maybe from our VPC module
    subnet_ids         = ["subnet-12312312", "subnet-23423423"]  # Put your private subnet IDs here, maybe from our VPC module
    engine             = "mysql"                                 # (optional, default mysql) Set to the type of [RDS engine](https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_CreateDBInstance.html) you want
    is_live            = false                                   # (optional, default false) Set to true for Multi-AZ
    instance_type      = "${var.instance_type}"                  # (optional, default db.t2.micro) Set the instance type
    security_group_ids = ["${aws_security_group.default.id}"]    # (optional) Add security group ids to this instance

    tags = {                                                     # (optional but recommended) Tag every resource this module creates
      Terraform = "true"
      Environment = "dev"
    }
}

# WARNING: In the above example, you should be using our terraform-tags
# module from https://github.com/olindata/terraform-tags instead of
# hardcoding tags like this bad example.  Please see examples in our
# templates folder of our terraform-aws repository.
```

This module does the following...

* **Creates an RDS Instance**
* **Automatically choosing sane default values for all settings depending on your input, such as...**
  * Multi-AZ Settings
  * Backup Settings
  * Backup/Upgrade schedule
  * Database Engine Version
* **Simplifies the input options to create an RDS to just what is necessary and/or typical to be modified**

Authors
-------

<br/>Module created and managed by [Farley](https://github.com/andrewfarley) and [OlinData](https://olindata.com/)

License
-------

Apache 2 Licensed. See LICENSE for full details.
