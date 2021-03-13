# Syntax

The connection between the Yaml configuration files and the actions taken by each command is explained in presentation available in [PowerPoint](yuruna.pptx) and [PDF](yuruna.pdf) formats.

## Parameters

The main PowerShell script named `yuruna` accepts the following parameters:

- `yuruna validate [project_root] [config_subfolder]`: Validate configuration files.
- `yuruna resources [project_root] [config_subfolder]`: Deploys resources using Terraform as helper (`terraform apply` executed in the configured work folder).
- `yuruna components [project_root] [config_subfolder]`: Build and push components to registry.
- `yuruna workloads [project_root] [config_subfolder]`: Deploy workloads using Helm as helper.
- `yuruna clear [project_root] [config_subfolder]`: Clear resources for given configuration (`terraform destroy` executed in the configured work folder).

You can execute commands in "debug mode" setting the `debug_mode` parameter to true. For example:

- `yuruna validate [project_root] [config_subfolder] -debug_mode $true`

You can also execute commands in "verbose mode" setting the `verbose_mode` parameter to true. It should come after the `debug_mode` parameter. For example:

- `yuruna validate [project_root] [config_subfolder] -debug_mode $true -verbose_mode $true`

Coming soon

- `yuruna requirements`: Check if machine has all requirements.

## Notes

- A folder `.yuruna` is create under the `project_root` for the temporary files.

Back to main [readme](../README.md)
