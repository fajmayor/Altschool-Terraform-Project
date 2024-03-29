resource "aws_s3_bucket" "altsch-proj-tf_backend_bucket" {
  bucket = var.bucket_name
  acl    = "private"
  versioning {
    enabled = true
  }

  tags = {
    Name        = "Altschool TF Project bucket"
    Environment = "Pro"
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = var.kms_master_key_id
        sse_algorithm     = var.kms_master_key_id == "" ? "AES256" : "aws:kms"
      }
    }
  }
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_dynamodb_table" "altsch-proj-tf-dynamodb-table" {
  count = var.aws_dynamodb_table_enabled ? 1 : 0
  name           = "terraform-state-lock"
  billing_mode   = "PROVISIONED"
  read_capacity  = var.read_capacity
  write_capacity = var.write_capacity
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Altschool-Project-TF-dynamodb-table-1"
    Environment = "prod"
  }
  
  lifecycle {
    prevent_destroy = false
  }

}

data "aws_iam_policy_document" "tf_backend_bucket_policy" {
  statement {
    sid = "1"
    effect = "Deny"

    actions = [
      "s3:*",
    ]

    resources = [
      "${aws_s3_bucket.altsch-proj-tf_backend_bucket.arn}/*",
      "${aws_s3_bucket.altsch-proj-tf_backend_bucket.arn}"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"

      values = [
        false,
      ]
    }

    principals {
      type = "*"
      identifiers = [ "*" ]
    }
  }

  statement {
    sid = "RequireEncryptedStorage"
    effect = "Deny"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "${aws_s3_bucket.altsch-proj-tf_backend_bucket.arn}/*",
    ]

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"

      values = [
        var.kms_master_key_id == "" ? "AES256" : "aws:kms"
      ]
    }

    principals {
      type = "*"
      identifiers = [ "*" ]
    }
  }
}


resource "aws_s3_bucket_policy" "tf_backend_policy" {
  bucket = aws_s3_bucket.altsch-proj-tf_backend_bucket.id
  policy = data.aws_iam_policy_document.tf_backend_bucket_policy.json
}