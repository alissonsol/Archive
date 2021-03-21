# `yuruna` examples

*NOTE*: Because some examples use the same ingress component and namespace, one may stop working after another using that component is deployed. If you "redeploy the ingress rules", then you can have the previously working example alive again! (And if you understood all this, you likely didn't need this warning anyway :-)

## Basic end-to-end test

- [website](website/README.md): A simple .NET C# website container deployed to a Kubernetes cluster.

## ONNX

Automating some ONNX examples.

- [ONNX GPT-2 training](onnx/training/gpt2/README.md): Accelerate GPT2 fine-tuning with ONNX Runtime Training

## peerkeys

- [peerkeys](peerkeys/README.md) demonstrates how to create and deploy resources to several clusters.

## Template

- This is just the [folder structure](./template/) to create a new project.
  - Copy and past folder structure to new folder.
  - Search and replace the template prefix (`yrn42template`) with the project name.

Back to main [readme](../../README.md)
