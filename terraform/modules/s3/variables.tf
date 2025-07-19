variable "bucket_name" {
    type = string
    description = "The name of the S3 bucket"
}

variable "tags" {
    type = map(string)
    description = "The tags to apply to the S3 bucket"
}