resource "aws_s3_bucket" "ansible_bucket" {
  bucket = "ansible-${data.aws_caller_identity.current.account_id}"
  acl    = "private"
}
