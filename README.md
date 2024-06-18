# coreml_modelc_profling
per op profiling in using Core ML [MLComputePlan](https://developer.apple.com/documentation/coreml/mlcomputeplan-85vdw?language=objc)

In iOS 17.4 / MacOS 15.4 or later. It's possible to get per-op profiling with MLComputePlan's [estimatedCostOfMLProgramOperation:](https://developer.apple.com/documentation/coreml/mlcomputeplan-85vdw/estimatedcostofmlprogramoperation:?language=objc) method.

1. prepare a compiled Core ML model (with `xcrun coremlc compile foo.mlpackage /tmp/`)
2. `coreml_profiing /tmp/foo.mlmodelc`

E.g., I got 
```
2024-06-13 16:59:10.628 coreml_profiling[67391:1771143] the mlmodelc directory: file:///tmp/MobilenetEdgeTPU.mlmodelc/ 
2024-06-13 16:59:10.784 coreml_profiling[67391:1771143] ML Program 
2024-06-13 16:59:10.785 coreml_profiling[67391:1771143] operation ios17.mul, device <MLCPUComputeDevice: 0x6000036e8170>, cost 4.6175%
2024-06-13 16:59:10.785 coreml_profiling[67391:1771143] operation ios17.add, device <MLCPUComputeDevice: 0x6000036e8170>, cost 3.6490%
2024-06-13 16:59:10.785 coreml_profiling[67391:1771143] operation ios17.cast, device <MLCPUComputeDevice: 0x6000036e8170>, cost 2.2767%
2024-06-13 16:59:10.785 coreml_profiling[67391:1771143] operation ios17.conv, device <MLNeuralEngineComputeDevice: 0x6000036ec0e0>, cost 0.5662%
2024-06-13 16:59:10.785 coreml_profiling[67391:1771143] operation ios16.relu, device <MLNeuralEngineComputeDevice: 0x6000036ec0e0>, cost 2.4627%
2024-06-13 16:59:10.785 coreml_profiling[67391:1771143] operation ios17.conv, device <MLNeuralEngineComputeDevice: 0x6000036ec0e0>, cost 4.5811%
2024-06-13 16:59:10.785 coreml_profiling[67391:1771143] operation ios17.conv, device <MLNeuralEngineComputeDevice: 0x6000036ec0e0>, cost 2.9749%
2024-06-13 16:59:10.785 coreml_profiling[67391:1771143] operation ios16.relu, device <MLNeuralEngineComputeDevice: 0x6000036ec0e0>, cost 2.4627%
2024-06-13 16:59:10.785 coreml_profiling[67391:1771143] operation ios17.conv, device <MLNeuralEngineComputeDevice: 0x6000036ec0e0>, cost 0.6614%
2024-06-13 16:59:10.785 coreml_profiling[67391:1771143] operation ios17.conv, device <MLNeuralEngineComputeDevice: 0x6000036ec0e0>, cost 3.0671%
2024-06-13 16:59:10.785 coreml_profiling[67391:1771143] operation ios16.relu, device <MLNeuralEngineComputeDevice: 0x6000036ec0e0>, cost 2.4627%
2024-06-13 16:59:10.785 coreml_profiling[67391:1771143] operation ios17.conv, device <MLNeuralEngineComputeDevice: 0x6000036ec0e0>, cost 0.6614%
2024-06-13 16:59:10.785 coreml_profiling[67391:1771143] operation ios17.add, device <MLNeuralEngineComputeDevice: 0x6000036ec0e0>, cost 1.8685%
....
```

Notes:
1. if the .mlmodelc is from old .mlmodel, add `-a` 
