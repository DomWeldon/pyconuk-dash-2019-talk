provider "aws" {
  region = "eu-west-2"
}

resource "aws_s3_bucket" "slides" {
  bucket = "${var.bucket_name}"
  acl    = "public-read"
  policy = <<EOF
{
"Version":"2012-10-17",
"Statement":[{
"Sid":"PublicReadGetObject",
      "Effect":"Allow",
  "Principal": "*",
    "Action":["s3:GetObject"],
    "Resource":["arn:aws:s3:::${var.bucket_name}/*"
    ]
  }
]
}
EOF
  website {
    index_document = "index.html"
  }
}


module "s3_user" {
  source       = "git::https://github.com/cloudposse/terraform-aws-iam-s3-user.git?ref=master"
  namespace    = "dom_talks"
  stage        = "prod"
  name         = "dom_talks_europython_2019"
  s3_actions   = ["s3:*"]
  s3_resources = ["arn:aws:s3:::${var.bucket_name}/*"]
}

output "aws_bucket_url" {
  value = "${aws_s3_bucket.slides.bucket_regional_domain_name}"
}

output "s3_user_access_key_id" {
  value = "${module.s3_user.access_key_id}"
}

output "s3_user_access_key_secret" {
  value = "${module.s3_user.secret_access_key}"
}
