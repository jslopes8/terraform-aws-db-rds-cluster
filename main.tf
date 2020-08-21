resource "aws_db_subnet_group" "main" {
    count = var.create ? length(var.db_subnet_group) : 0

    name       = lookup(var.db_subnet_group[count.index], "name", null)
    subnet_ids = lookup(var.db_subnet_group[count.index], "subnet_ids", null)

    tags = merge(
        {
            "Name" = "${format("%s", var.cluster_name)}-Subnet-Group"
        },
        var.default_tags,
  )
}
data "aws_iam_policy_document" "enhanced_monitoring" {
    count = var.create_monitoring_role ? 1 : 0

    statement {
        actions = [
            "sts:AssumeRole",
        ]

        principals {
            type        = "Service"
            identifiers = ["monitoring.rds.amazonaws.com"]
        }
    }
}
resource "aws_iam_role" "enhanced_monitoring" {
    count = var.create_monitoring_role ? 1 : 0

    name               = "${var.cluster_name}-MonitoringRole"
    assume_role_policy = data.aws_iam_policy_document.enhanced_monitoring.0.json

    tags = merge(
        {
            "Name" = "${format("%s", var.cluster_name)}-MonitoringRole"
        },
        var.default_tags,
  )
}
resource "aws_iam_role_policy_attachment" "enhanced_monitoring" {
    count = var.create_monitoring_role ? 1 : 0

    role       = aws_iam_role.enhanced_monitoring[0].name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_rds_cluster" "main" {
    count = var.create ? 1 : 0////

    cluster_identifier      = lower(replace(var.cluster_name, " ", "-"))
    engine                  = var.engine
    engine_version          = var.engine_version
    engine_mode             = var.engine_mode
    deletion_protection     = var.deletion_protection
    source_region           = var.source_region
    availability_zones      = var.availability_zones
    database_name           = var.database_name
    master_username         = var.master_username
    master_password         = var.master_password
    vpc_security_group_ids  = var.vpc_security_group_ids
    backup_retention_period = var.backup_retention_period
    preferred_backup_window = var.preferred_backup_window
    copy_tags_to_snapshot   = var.copy_tags_to_snapshot
    storage_encrypted       = var.storage_encrypted
    
    snapshot_identifier             = var.snapshot_identifier
    skip_final_snapshot             = var.skip_final_snapshot
    final_snapshot_identifier       = "${lower(replace(var.cluster_name, " ", "-"))}-${random_id.snapshot_identifier.0.hex}-final-snapshot"

    enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

    db_cluster_parameter_group_name = var.db_parameter_group_name
    db_subnet_group_name            = aws_db_subnet_group.main.0.id
    tags    = merge(
        {
            "Name"  =   "${var.cluster_name}"
        },
        "${var.default_tags}"
    )
}
resource "random_id" "snapshot_identifier" {
    count = var.create ? 1 : 0

    byte_length = 4
    keepers = {
        id = var.cluster_name
    }
}
resource "aws_rds_cluster_instance" "main" {
    count = var.create ? var.replica_count : 0

    promotion_tier                  = count.index + 1
    #availability_zone               = var.availability_zones
    identifier                      = "${var.cluster_name}-instance-${count.index + 1}"
    cluster_identifier              = aws_rds_cluster.main.0.id
    engine                          = aws_rds_cluster.main.0.engine
    engine_version                  = aws_rds_cluster.main.0.engine_version
    instance_class                  = var.instance_type
    publicly_accessible             = var.publicly_accessible
    db_subnet_group_name            = var.db_subnet_group_name
    db_parameter_group_name         = var.db_parameter_group_name
    preferred_maintenance_window    = var.preferred_maintenance_window
    apply_immediately               = var.apply_immediately
    auto_minor_version_upgrade      = var.auto_minor_version_upgrade
    performance_insights_enabled    = var.performance_insights_enabled
    ca_cert_identifier              = var.ca_cert_identifier
    
    monitoring_role_arn = coalesce(var.monitoring_role_arn, aws_iam_role.enhanced_monitoring.*.arn, null)
    monitoring_interval = var.monitoring_interval

    tags = var.default_tags
}
resource "aws_appautoscaling_target" "main" {
    count = var.create && var.enable_read_replica ? 1 : 0

    service_namespace  = "rds"
    max_capacity       = var.replica_scale_max
    min_capacity       = var.replica_scale_min
    resource_id        = "cluster:${aws_rds_cluster.main.0.cluster_identifier}"
    scalable_dimension = "rds:cluster:ReadReplicaCount"
}
resource "aws_appautoscaling_policy" "main" {
    depends_on = [ aws_appautoscaling_target.main ]

    count = var.create && var.enable_read_replica ? length(var.scaling_policy) : 0
    
    name                = lookup(var.scaling_policy[count.index], "name", null)
    service_namespace   = aws_appautoscaling_target.main.0.service_namespace
    scalable_dimension  = aws_appautoscaling_target.main.0.scalable_dimension
    resource_id         = aws_appautoscaling_target.main.0.resource_id
    policy_type         = lookup(var.scaling_policy[count.index], "policy_type", null)

    target_tracking_scaling_policy_configuration {        
        predefined_metric_specification {
            predefined_metric_type = lookup(var.scaling_policy[count.index], "metric_type", null)
        }
        target_value       = lookup(var.scaling_policy[count.index], "target_value", null)
        scale_in_cooldown  = lookup(var.scaling_policy[count.index], "scale_in_cooldown", null)
        scale_out_cooldown = lookup(var.scaling_policy[count.index], "scale_out_cooldown", null)
    }
}
