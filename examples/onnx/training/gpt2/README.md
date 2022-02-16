# `yuruna` ONNX training example: huggingface-gpt2

PREVIEW NOTE: The final `workloads` step is still being debugged.

Based on example [Accelerate GPT2 fine-tuning with ONNX Runtime Training](https://github.com/microsoft/onnxruntime-training-examples/tree/master/huggingface-gpt2)

## Search and replace

Reuse this project by search and replacing placeholders in case-sensitive mode.

- yrn42onnxtraingpt2-prefix -> Common project prefix for containers. Example: yrn42
- yrn42onnxtraingpt2-ns -> Kubernetes namespace for installing containers. Example: yrn42
- yrn42onnxtraingpt2-dns -> DNS prefix. Example: yrn42
- yrn42onnxtraingpt2-rg -> Name for group of resources (Azure). Example: yrn42
- yrn42onnxtraingpt2-tags -> Resource tags. Example: yrn42
- yrn42onnxtraingpt2-cluster -> Name for the K8S cluster (or at least a common prefix). Example: yrn42

Despite the several placeholders enabling reuse in different configurations, it is recommended to replace as many valuables as possible to become identical, easing future maintenance. Replace `yrn42onnxtraingpt2-tags` first and then use this regular expression to search and replace the others:  `(yrn42onnxtraingpt2)[A-Za-z0-9\-]*`

Before deploying to the cloud environments, seek for `TO-SET` and set the required values. See section "Cloud deployment instructions".

## End to end deployment

Below are the end-to-end steps to deploy the `website` project to `localhost` (assuming Docker is installed and Kubernetes enabled). The execution below is from the `automation` folder. You may need to start PowerShell (`pwsh`).

**IMPORTANT**: Before proceeding, read the Connectivity section of the [Frequently Asked Questions](../../../../docs/faq.md).

- Create resources

```shell
./yuruna.ps1 resources ../examples/onnx/training/gpt2 localhost
```

- Build the components

```shell
./yuruna.ps1 components ../examples/onnx/training/gpt2 localhost
```

- Deploy the  workloads

PREVIEW NOTE: This step is still under development. The [`helper`](./workloads/helper/) folder has scripts for each of the phases being integrated and tested.

```shell
./yuruna.ps1 workloads ../examples/onnx/training/gpt2 localhost
```

## Resources

Terraform will be used to create the following resources:

- A Kubernetes cluster

As output, the following values will become available for later steps:

- registryLocation

## Components

- Image `dataload`: based on Linux, with script to download and prepare data.
- Image `tuning`: based on onnxruntime, with steps for model tuning.

## Workloads

- Container `dataload`: loads data into a persistent volume claim. Will be a [init container](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/).
- Container `tuning`: executes the tuning phase.

Back to main [readme](../../../../README.md). Back to list of [examples](../../../README.md).
