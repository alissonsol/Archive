resource "null_resource" "context" {
  provisioner "local-exec" {
    command = "./context-copy.ps1"
    interpreter = local.is_windows ? ["PowerShell", "-Command"] : ["pwsh", "-Command"]

    environment = {
      SOURCE_CONTEXT = var.sourceContext
      DESTINATION_CONTEXT = var.destinationContext
    }
  }
}
