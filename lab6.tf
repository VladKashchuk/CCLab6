provider "aws"{
    region = "us-east-1"
    access_key = "AKIAU2JSP4Q5RI55CFAR"
    secret_key = "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"
}

resource "aws_security_group" "lab6" {
    name = "lab6"
    vpc_id = "vpc-39915e44"
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lab6"
  }
}

resource "aws_instance" "myWebServer" {
  count = 2
  ami = "ami-09aee72a39e1faffc"
  instance_type =  "t2.micro"
  key_name = "VladKey"
  disable_api_termination = true
  security_groups = [ aws_security_group.lab6.name ]

  user_data = file("script.sh")

  tags = {
     Name = format("lab6-i-%d", count.index)
   }

}

resource "aws_lb" "elbLab6" {
  name = "elbLab6"
  internal = false
  load_balancer_type = "application"
  security_groups = [ aws_security_group.lab6.id ]
  subnets = [ "subnet-2af5b667", "subnet-b3a91ad5" ]

  tags = {
    Name = "elbLab6"
  }
}

resource "aws_lb_target_group" "tg-lab6" {
  name     = "lab6-target-group"
  target_type = "instance"
  port     = 80
  protocol = "HTTP"
  vpc_id = "vpc-39915e44"
}

resource "aws_lb_target_group_attachment" "TgAttach" {
  target_group_arn = aws_lb_target_group.tg-lab6.arn
  count = length(aws_instance.myWebServer)
  target_id = aws_instance.myWebServer[count.index].id
  port = 80
}

resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.elbLab6.arn
    port = 80
    protocol = "HTTP"

  default_action {
      type             = "forward"
      target_group_arn = aws_lb_target_group.tg-lab6.arn
    }
  }
