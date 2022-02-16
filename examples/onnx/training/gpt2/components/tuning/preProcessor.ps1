# Automating steps from https://github.com/microsoft/onnxruntime-training-examples/tree/master/huggingface-gpt2
# One letter folder "t" (tmp) used to keep paths short
Remove-Item -Path t -Force -Recurse -ErrorAction SilentlyContinue
git config --global core.autocrlf input
git clone https://github.com/microsoft/onnxruntime-training-examples.git t
Set-Location t/huggingface-gpt2
git clone https://github.com/huggingface/transformers.git
Set-Location transformers/
git checkout 9a0a8c1c6f4f2f0c80ff07d36713a3ada785eec5
git apply ../ort_addon/src_changes.patch
Copy-Item -Recurse ../ort_addon/ort_supplement/* ./ -Force
Set-Location ..
