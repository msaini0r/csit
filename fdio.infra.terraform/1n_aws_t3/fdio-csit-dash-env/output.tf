output "elastic_beanstalk_environment_hostname" {
  description = "DNS hostname"
  value       = module.elastic_beanstalk_environment.cname
}

output "elastic_beanstalk_environment_name" {
  description = "Name of the Elastic Beanstalk environment"
  value       = module.elastic_beanstalk_environment.envName
}