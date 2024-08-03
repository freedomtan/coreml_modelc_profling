#import <CoreML/CoreML.h>
#include <getopt.h>

// hack: use class extension to export setProfilingOptions:
@interface MLModelConfiguration()
-(id) setProfilingOptions: (long long) p;
@end

// hack: use class extension to export program:
@interface MLModel()
-(id) program;
@end

// hack: export programLibrary and segmentationAnalyticsAndReturnError
//       of MLE5Engine
@interface MLE5Engine
-(id) programLibrary;
-(NSDictionary *) segmentationAnalyticsAndReturnError: (id *)error;
@end

void profile_it(NSURL *modelURL) {
  MLModelConfiguration *configuration = [[MLModelConfiguration alloc] init];

  // enable profling options then we can do 
  [configuration setProfilingOptions: 1];

  MLModel *loaded = [MLModel modelWithContentsOfURL:modelURL configuration: configuration error: nil];

  NSDictionary *d = [[[loaded program] programLibrary] segmentationAnalyticsAndReturnError: nil];
  for (id k in d)
    NSLog(@"%@, %@ ", k, d[k]); 
}

void usage() { return; }

int main(int argc, char *argv[]) {
  char *coreml_model_file;
  const char *mobilenet = "/tmp/MobileNet.mlmodelc";

  if (argc < 2) {
    coreml_model_file = (char *)mobilenet;
  } else {
    coreml_model_file = argv[1];
  }

  NSURL *testURL = [NSURL fileURLWithPath:[NSString stringWithUTF8String:coreml_model_file]];
  NSLog(@"the mlmodelc directory: %@ ", [testURL absoluteURL]);

  profile_it(testURL);

  exit(0);
}
