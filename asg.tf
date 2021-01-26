module "asg" {
  source          = "git::https://github.com/nikkaushal/terraform-asg.git"
  COMPONENT       = var.COMPONENT
  ENV             = var.ENV
  INSTANCE_TYPE   = var.INSTANCE_TYPE
  bucket          = var.bucket
  region          = var.region
  PORT            = 8080
  HEALTH          = "/health"
}

resource "aws_lb_listener_rule" "catalogue" {
  listener_arn        = data.terraform_remote_state.alb.outputs.PRIVATE_ALB_LISTENER_ARN
  action              {
    type             = "forward"
    target_group_arn = module.asg.TG_ARN
  }
  condition            {
   host_header        {
     values         = ["${var.COMPONENT}-${var.ENV}.devopsnik.tk"]
   }
  }

}

resource "aws_route53_record" "alb" {
  zone_id = "Z0869909I3INDIN3CQDX"
  name    = "${var.COMPONENT}-${var.ENV}.devopsnik.tk"
  type    = "CNAME"
  ttl     = "300"
  records = [data.terraform_remote_state.alb.outputs.PRIVATE_ALB_DNS]
}