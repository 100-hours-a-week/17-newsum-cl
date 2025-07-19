module "s3" {
    source = "../../modules/s3"
    bucket_name = "newsum-web-stage"
    tags = {
        Name = "newsum-web-stage"
        Environment = "stage"
    }
}