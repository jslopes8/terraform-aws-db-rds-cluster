variable "create" {
    type = bool  
    default = true
}
variable "create_monitoring_role" {
    type = bool  
    default = false
}
variable "cluster_name" {
    type = string
}
variable "engine" {
    type = string 
}
variable "engine_mode" {
    type = string  
    default = "provisioned"
}
variable "engine_version" {
    type = string 
}
variable "availability_zones" {
    type = list 
    default = []
}
variable "database_name" {
    type = string 
}
variable "master_username" {
    type = string
}
variable "master_password" {
    type = string 
}
variable "instance_type" {
    type = string
}
variable "publicly_accessible" {
    type = bool  
    default = false
}
variable "preferred_maintenance_window" {
    type = string 
    default = null
}
variable "apply_immediately" {
    type = bool 
    default = false
}
variable "auto_minor_version_upgrade" {
    type = bool 
    default = true
}
variable "performance_insights_enabled" {
    type = bool 
    default = false
}
variable "vpc_security_group_ids" {
    type = list
    default = []
}
variable "ca_cert_identifier" {
    type    = string
    default = "rds-ca-2019"
}
variable "backup_retention_period" {
    type = number
    default = "1"
}
variable "preferred_backup_window" {
    type = string
    default = null
}
variable "copy_tags_to_snapshot" {
    type = bool 
    default = true
}
variable "replica_count" {
    type = number 
    default = "1"
}
variable "storage_encrypted" {
    type = bool 
    default = false
}
variable "snapshot_identifier" {
    type = string
    default = null
}
variable "enabled_cloudwatch_logs_exports" {
    type = any 
    default = []
}
variable "db_parameter_group_name" {
    type = string
    default = null 
}
variable "db_subnet_group_name" {
    type = string
    default = "default"
}
variable "enable_read_replica" {
    type = bool  
    default = false
}
variable "replica_scale_max" {
    type = number 
    default = "2"
}
variable "deletion_protection" {
    type = bool 
    default = false
}
variable "replica_scale_min" {
    type = number 
    default = "0"
}
variable "scaling_policy" {
    type = any 
    default = []
}
variable "default_tags" {
    type = map(string)
    default = {}
}
variable "monitoring_interval" {
    type = number
    default = "0"
}
variable "monitoring_role_arn" {
    type    = string
    default = ""
}
variable "skip_final_snapshot" {
    type = bool 
    default = true
}
variable "source_region" {
    type = string 
    default = "us-east-1"
}