
data "aws_vpc" "eks_vpc" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_subnets" "public_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.eks_vpc.id]
  }
  filter {
    name   = "tag:Name"
    values = ["$${var.vpc_name}-public-*"]
  }
}

data "aws_subnets" "private_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.eks_vpc.id]
  }
  filter {
    name   = "tag:Name"
    values = ["$${var.vpc_name}-private-*"]
  }
}
