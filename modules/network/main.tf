
resource "aws_vpc" "staging_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = "false" 
  enable_dns_hostnames = "true" 
  instance_tenancy     = "default"

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_vpc_ipv4_cidr_block_association" "secondary_cidr" {
  count = length(var.secondary_vpc_cidr)
  vpc_id        = aws_vpc.staging_vpc.id
  cidr_block    = var.secondary_vpc_cidr[count.index]

}
resource "aws_internet_gateway" "staging_vpc_igw" {
  vpc_id = aws_vpc.staging_vpc.id

  tags = {
    Name = var.igw_name

  }
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_subnet" "public_subnet" {
  count = length(var.public_subnet_cidr_blocks)

  cidr_block                          = var.public_subnet_cidr_blocks[count.index]
  vpc_id                              = aws_vpc.staging_vpc.id
  map_public_ip_on_launch             = true 
  private_dns_hostname_type_on_launch = "ip-name"
  availability_zone                   = element(var.availability_zones, count.index)

  tags = {
    Name = "${var.public_subnet_name_prefix}-${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnet" {
  count = length(var.private_subnet_cidr_blocks)

  cidr_block                          = var.private_subnet_cidr_blocks[count.index]
  private_dns_hostname_type_on_launch = "ip-name"
  vpc_id                              = aws_vpc.staging_vpc.id
  availability_zone                   = element(var.availability_zones, count.index)

  tags = {
    Name = "${var.private_subnet_name_prefix}-${count.index + 1}"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.staging_vpc.id
  count  = length(aws_subnet.public_subnet)

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.staging_vpc_igw.id
  }
  tags = {
    Name = "${var.public_rt_name}-${count.index + 1}"
  }
}


resource "aws_route_table" "private_rt" {
  count  = length(aws_subnet.private_subnet)
  vpc_id = aws_vpc.staging_vpc.id
  tags = {
    Name = "${var.private_rt_name}-${count.index + 1}"
  }
}


resource "aws_route_table_association" "public_rt_association" {
  count          = length(aws_subnet.public_subnet)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt[count.index].id
}


resource "aws_route_table_association" "private_rt_association" {
  count          = length(aws_subnet.private_subnet)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_rt[count.index].id
}

