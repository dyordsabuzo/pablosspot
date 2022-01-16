locals {
    volume_mapping = [
        {
            name = "nginx-conf"
            host_path = "/var/nginx"
            containerPath = "/etc/nginx/conf.d"
            readOnly = true
        }
    ]
}
