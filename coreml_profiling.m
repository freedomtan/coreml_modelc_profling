#import <CoreML/CoreML.h>
// #include <unistd.h>
#include <getopt.h>

@interface MLComputePlan (CategoryName)
+ (MLComputePlan *)computePlanOfModelAtURL:(NSURL *)url
                             configuration:(MLModelConfiguration *)configuration
                                     error:(NSError *_Nullable)error;
@end

void check_mlprogram(MLComputePlan *computePlan, MLModelStructureProgram *program) {
  if (!program) {
    [NSException raise:NSInternalInconsistencyException format:@"Unexpected model type."];
  }

  MLModelStructureProgramFunction *mainFunction = program.functions[@"main"];
  if (!mainFunction) {
    [NSException raise:NSInternalInconsistencyException format:@"Missing main function."];
  }

  NSArray<MLModelStructureProgramOperation *> *operations = mainFunction.block.operations;
  for (MLModelStructureProgramOperation *operation in operations) {
    // Get the compute device usage for the operation.
    MLComputePlanDeviceUsage *computeDeviceUsage =
        [computePlan computeDeviceUsageForMLProgramOperation:operation];
    // Get the estimated cost of executing the operation.
    MLComputePlanCost *estimatedCost = [computePlan estimatedCostOfMLProgramOperation:operation];
    if ((estimatedCost) && (computeDeviceUsage)) {
      NSLog(@"operation %@, device %@, cost %lf us", [operation operatorName],
            [computeDeviceUsage preferredComputeDevice], [estimatedCost weight] * 1e3);
    }
  }
}

void check_neural_network(MLComputePlan *computePlan, MLModelStructureNeuralNetwork *nn) {
  if (!nn) {
    [NSException raise:NSInternalInconsistencyException format:@"Unexpected model type."];
  }

  NSArray<MLModelStructureNeuralNetworkLayer *> *layers = nn.layers;
  for (MLModelStructureNeuralNetworkLayer *layer in layers) {
    // no way to get estimated cost of each layer??
    MLComputePlanDeviceUsage *computeDeviceUsage =
        [computePlan computeDeviceUsageForNeuralNetworkLayer:layer];
    if (computeDeviceUsage) {
      NSLog(@"layer %@, device %@", [layer name], [computeDeviceUsage preferredComputeDevice]);
    }
  }
}

void load_the_plan(NSURL *modelURL) {
  MLModelConfiguration *configuration = [[MLModelConfiguration alloc] init];

  MLComputePlan *computePlan = [MLComputePlan computePlanOfModelAtURL:modelURL
                                                        configuration:configuration
                                                                error:nil];

  MLModelStructure *modelStructure = [computePlan modelStructure];
  if (!modelStructure) {
    [NSException raise:NSInternalInconsistencyException format:@"no modelStructure."];
    return;
  }
  if (modelStructure.neuralNetwork) {
    // Examine Neural network model.
    NSLog(@"Neural Network\n");
    check_neural_network(computePlan, modelStructure.neuralNetwork);
  } else if (modelStructure.program) {
    // Examine ML Program model.
    NSLog(@"ML Program \n");
    check_mlprogram(computePlan, modelStructure.program);
  } else if (modelStructure.pipeline) {
    // Examine Pipeline model.
    NSLog(@"ML Pipeline \n");
  } else {
    // The model type is something else.
  }
}

void load_the_plan_async(NSURL *modelURL) {
  MLModelConfiguration *configuration = [[MLModelConfiguration alloc] init];

  [MLComputePlan
      loadContentsOfURL:modelURL
          configuration:configuration
      completionHandler:^(MLComputePlan *_Nullable computePlan, NSError *_Nullable error) {
        MLModelStructure *modelStructure = [computePlan modelStructure];

        if (!modelStructure) {
          [NSException raise:NSInternalInconsistencyException format:@"no modelStructure."];
          return;
        }
        if (modelStructure.neuralNetwork) {
          // Examine Neural network model.
          NSLog(@"Neural Network\n");
          check_neural_network(computePlan, modelStructure.neuralNetwork);
        } else if (modelStructure.program) {
          // Examine ML Program model.
          NSLog(@"ML Program \n");
          check_mlprogram(computePlan, modelStructure.program);
        } else if (modelStructure.pipeline) {
          // Examine Pipeline model.
          NSLog(@"ML Pipeline \n");
        } else {
          // The model type is something else.
        }
      }];
}

void usage() { return; }

int main(int argc, char *argv[]) {
  char *coreml_model_file;
  const char *mobilenet = "/tmp/MobileNet.mlmodelc";

  int ch;
  bool async = false;
  while ((ch = getopt(argc, argv, "a")) != -1) {
    switch (ch) {
      case 'a':
        async = true;
        break;
      default:
        usage();
        break;
    }
  }
  argc -= optind;
  argv += optind;

  if (argc < 1) {
    coreml_model_file = (char *)mobilenet;
  } else {
    coreml_model_file = argv[0];
  }

  NSURL *testURL = [NSURL fileURLWithPath:[NSString stringWithUTF8String:coreml_model_file]];
  NSLog(@"the mlmodelc directory: %@ ", [testURL absoluteURL]);

  if (async) {
    load_the_plan_async(testURL);
    sleep(3);
  } else {
    load_the_plan(testURL);
  }

  exit(0);
}
