resource "aws_s3_bucket" "ansible_bucket" {
  bucket = "acg-demo-lambda"
  acl    = "private"
}
