output "vpc_id" {
  value = module.student_management_vpc.vpc_id
}

output "vpc_arn" {
  value = module.student_management_vpc.vpc_arn
}

output "public_subnet_ids" {
  value = module.student_management_vpc.public_subnets
}

output "private_subnet_ids" {
  value = module.student_management_vpc.private_subnets
}
