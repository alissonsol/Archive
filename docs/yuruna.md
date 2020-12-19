# Yuruna

The connection between the Yaml configuration files and the actions taken by each command is explained in presentation available in [PowerPoint](yuruna.pptx) and [PDF](yuruna.pdf) formats.

## Syntax

The main PowerShell script named `yuruna` accepts the following parameters:

- `yuruna validate [project_root] [config_subfolder]`: Validate configuration files.
- `yuruna resources [project_root] [config_subfolder]`: Deploys resources using Terraform as helper.
- `yuruna components [project_root] [config_subfolder]`: Build and push components to registry.
- `yuruna workloads [project_root] [config_subfolder]`: Deploy workloads using Helm as helper.

## Notes

- A folder `.yuruna` is create under the `project_root` for the temporary files.

Back to main [readme](../README.md)
