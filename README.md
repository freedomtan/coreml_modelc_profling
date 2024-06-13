# coreml_modelc_profling
per op profiling in using Core ML [MLComputePlan](https://developer.apple.com/documentation/coreml/mlcomputeplan-85vdw?language=objc)

In iOS 17.4 / MacOS 15.4 or later. It's possible to get per-op profiling with MLComputePlan's [estimatedCostOfMLProgramOperation:](https://developer.apple.com/documentation/coreml/mlcomputeplan-85vdw/estimatedcostofmlprogramoperation:?language=objc) method.

1. prepare a compiled Core ML model (with `xcrun coremlc compile foo.mlpackage /tmp/`)
2. `coreml_profiing /tmp/foo.mlmodelc`

E.g., I got 
```
2024-06-13 20:50:46.742 coreml_profiling[43991:7696208] the mlmodelc directory: file:///tmp/MobilenetEdgeTPU.mlmodelc/ 
2024-06-13 20:50:47.804 coreml_profiling[43991:7696208] ML Program 
2024-06-13 20:50:47.805 coreml_profiling[43991:7696208] operation ios17.mul, device <MLCPUComputeDevice: 0x60000260e430>, cost 46.175446 us
2024-06-13 20:50:47.805 coreml_profiling[43991:7696208] operation ios17.add, device <MLCPUComputeDevice: 0x60000260e430>, cost 36.490350 us
2024-06-13 20:50:47.805 coreml_profiling[43991:7696208] operation ios17.cast, device <MLCPUComputeDevice: 0x60000260e430>, cost 22.766798 us
2024-06-13 20:50:47.805 coreml_profiling[43991:7696208] operation ios17.conv, device <MLNeuralEngineComputeDevice: 0x6000026167f0>, cost 5.661668 us
2024-06-13 20:50:47.805 coreml_profiling[43991:7696208] operation ios16.relu, device <MLNeuralEngineComputeDevice: 0x6000026167f0>, cost 24.626741 us
2024-06-13 20:50:47.805 coreml_profiling[43991:7696208] operation ios17.conv, device <MLNeuralEngineComputeDevice: 0x6000026167f0>, cost 45.811273 us
2024-06-13 20:50:47.805 coreml_profiling[43991:7696208] operation ios17.conv, device <MLNeuralEngineComputeDevice: 0x6000026167f0>, cost 29.749493 us
2024-06-13 20:50:47.805 coreml_profiling[43991:7696208] operation ios16.relu, device <MLNeuralEngineComputeDevice: 0x6000026167f0>, cost 24.626741 us
2024-06-13 20:50:47.805 coreml_profiling[43991:7696208] operation ios17.conv, device <MLNeuralEngineComputeDevice: 0x6000026167f0>, cost 6.613858 us
2024-06-13 20:50:47.805 coreml_profiling[43991:7696208] operation ios17.conv, device <MLNeuralEngineComputeDevice: 0x6000026167f0>, cost 30.671379 us
2024-06-13 20:50:47.805 coreml_profiling[43991:7696208] operation ios16.relu, device <MLNeuralEngineComputeDevice: 0x6000026167f0>, cost 24.626741 us
2024-06-13 20:50:47.805 coreml_profiling[43991:7696208] operation ios17.conv, device <MLNeuralEngineComputeDevice: 0x6000026167f0>, cost 6.613858 us
2024-06-13 20:50:47.805 coreml_profiling[43991:7696208] operation ios17.add, device <MLNeuralEngineComputeDevice: 0x6000026167f0>, cost 18.685220 us
....
```
