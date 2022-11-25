resource "aws_vpc" "vpc_example" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "vpc_example"
    }
}

resource "aws_subnet" "public_subnet1" {
    vpc_id = aws_vpc.vpc_example.id
    cidr_block = "10.0.1.0/24"
    tags = {
        Name = "public_subnet1"
    }
}

resource "aws_subnet" "public_subnet2" {
    vpc_id = aws_vpc.vpc_example.id
    cidr_block = "10.0.2.0/24"
    tags = {
        Name = "public_subnet2"
    }
}

resource "aws_subnet" "private_subnet1" {
    vpc_id = aws_vpc.vpc_example.id
    cidr_block = "10.0.10.0/24"
    tags = {
        Name = "private_subnet1"
    }
}

resource "aws_subnet" "private_subnet2" {
    vpc_id = aws_vpc.vpc_example.id
    cidr_block = "10.0.20.0/24"
    tags = {
        Name = "private_subnet2"
    }
}

resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.vpc_example.id
    tags = {
        Name = "gw"
    }
}

resource "aws_eip" "loadbalancer1" {
    vpc = true
    tags = {
        Name = "loadbalancer1"
    }
}

resource "aws_eip" "loadbalancer2" {
    vpc = true
    tags = {
        Name = "loadbalancer2"
    }
}

resource "aws_nat_gateway" "nat1" {
    allocation_id = aws_eip.loadbalancer1.id
    subnet_id = aws_subnet.public_subnet1.id
    tags = {
        Name = "nat1"
    }
}

resource "aws_nat_gateway" "nat2" {
    allocation_id = aws_eip.loadbalancer2.id
    subnet_id = aws_subnet.public_subnet2.id
    tags = {
        Name = "nat2"
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

resource "aws_route_table" "private_route_table1" {
    vpc_id = aws_vpc.vpc_example.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat1.id
    }
    tags = {
        Name = "private_route_table1"
    }
}

resource "aws_route_table" "private_route_table2" {
    vpc_id = aws_vpc.vpc_example.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat2.id
    }
    tags = {
        Name = "private_route_table2"
    }
}

resource "aws_route_table_association" "public_route_association1" {
    subnet_id = aws_subnet.public_subnet1.id
    route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_route_association2" {
    subnet_id = aws_subnet.public_subnet2.id
    route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_route_association1" {
    subnet_id = aws_subnet.private_subnet1.id
    route_table_id = aws_route_table.private_route_table1.id
}

resource "aws_route_table_association" "private_route_association2" {
    subnet_id = aws_subnet.private_subnet2.id
    route_table_id = aws_route_table.private_route_table2.id
}