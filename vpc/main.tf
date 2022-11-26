locals {
    public_cidr = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24"]
    private_cidr = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24", "10.0.40.0/24"]
}

resource "aws_vpc" "vpc_example" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "vpc_example"
    }
}

resource "aws_subnet" "public_subnet" {
    count = 4

    vpc_id = aws_vpc.vpc_example.id
    cidr_block = local.public_cidr[count.index]
    tags = {
        Name = "public_subnet${count.index}"
    }
}

resource "aws_subnet" "private_subnet" {
    count = length(local.private_cidr)

    vpc_id = aws_vpc.vpc_example.id
    cidr_block = local.private_cidr[count.index]
    tags = {
        Name = "private_subnet${count.index}"
    }
}

resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.vpc_example.id
    tags = {
        Name = "gw"
    }
}

resource "aws_eip" "loadbalancer" {
    count = length(local.public_cidr)
    
    vpc = true
    tags = {
        Name = "loadbalancer${count.index}"
    }
}

resource "aws_nat_gateway" "nat" {
    count = length(local.public_cidr)

    allocation_id = aws_eip.loadbalancer[count.index].id
    subnet_id = aws_subnet.public_subnet[count.index].id
    tags = {
        Name = "nat${count.index}"
    }
}

resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.vpc_example.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gw.id
    }
    tags = {
        Name = "public_route_table"
    }
}

resource "aws_route_table" "private_route_table" {
    count = length(local.private_cidr)
    
    vpc_id = aws_vpc.vpc_example.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat[count.index].id
    }
    tags = {
        Name = "private_route_table${count.index}"
    }
}

resource "aws_route_table_association" "public_route_association" {
    count = length(local.public_cidr)

    subnet_id = aws_subnet.public_subnet[count.index].id
    route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_route_association" {
    count = length(local.private_cidr)

    subnet_id = aws_subnet.private_subnet[count.index].id
    route_table_id = aws_route_table.private_route_table[count.index].id
}