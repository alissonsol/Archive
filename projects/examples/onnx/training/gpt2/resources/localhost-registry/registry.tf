resource "null_resource" "registry" {
  provisioner "local-exec" {
    command = "docker run -d -p 5000:5000 --restart always --name registry registry:latest"
    interpreter = local.is_windows ? ["PowerShell", "-Command"] : []
  }
}