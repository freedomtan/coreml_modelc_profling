#import <CoreML/CoreML.h>
#include <getopt.h>

// hack: use class extension to export setProfilingOptions:
@interface MLModelConfiguration ()
- (id)setProfilingOptions:(long long)p;
@end

// hack: use class extension to export program:
@interface MLModel ()
- (id)program;
@end

// hack: export programLibrary and segmentationAnalyticsAndReturnError
//       of MLE5Engine
@interface MLE5Engine
- (id)programLibrary;
- (NSDictionary *)segmentationAnalyticsAndReturnError:(id *)error;
@end

void profile_it(NSURL *modelURL) {
  MLModelConfiguration *configuration = [[MLModelConfiguration alloc] init];

  // enable profling options then we can do
  [configuration setProfilingOptions:1];

  MLModel *loaded = [MLModel modelWithContentsOfURL:modelURL configuration:configuration error:nil];

  NSDictionary *d = [[[loaded program] programLibrary] segmentationAnalyticsAndReturnError:nil];
  NSArray *allKeys = [d allKeys];

  NSArray *sortedKeys = [allKeys sortedArrayUsingComparator:^(id obj1, id obj2) {
    // keys are filename:line_no:column_no, we sort the keys by line number
    id loc_1 = [obj1 componentsSeparatedByString:@":"][1];
    id loc_2 = [obj2 componentsSeparatedByString:@":"][1];

    if ([loc_1 integerValue] > [loc_2 integerValue]) {
      return (NSComparisonResult)NSOrderedDescending;
    }
    if ([obj1 integerValue] < [obj2 integerValue]) {
      return (NSComparisonResult)NSOrderedAscending;
    }
    return (NSComparisonResult)NSOrderedSame;
  }];

  int max_backends = 0;
  NSArray *all_backends = [[NSArray alloc] init];
  for (id i in sortedKeys) {
    if ([d[i][@"BackendSupport"] count] > max_backends) {
      max_backends = [d[i][@"BackendSupport"] count];
      all_backends = [d[i][@"BackendSupport"] allKeys];
    }
  }

  for (id k in sortedKeys) {
    NSString *backends = @"";
    NSString *estimateds = @"";
    NSString *error_messages = @"";
    NSArray *supportedBackends = [d[k][@"BackendSupport"] allKeys];
    NSArray *estimated = [d[k][@"EstimatedRunTime"] allKeys];
    NSArray *validation_messages = [d[k][@"ValidationMessages"] allKeys];
    // NSLog(@"%@", supportedBackends);
    // NSLog(@"%@", estimated);

    for (int i = 0; i < max_backends; i++) {
      if ([supportedBackends containsObject:all_backends[i]]) {
        if (i < (max_backends - 1)) {
          backends = [backends stringByAppendingString:all_backends[i]];
          backends = [backends stringByAppendingString:@", "];
        } else {
          backends = [backends stringByAppendingString:all_backends[i]];
        }
      } else {
        backends = [backends stringByAppendingString:@", "];
      }

      if ([estimated containsObject:all_backends[i]]) {
        if (i < (max_backends - 1)) {
          estimateds = [estimateds
              stringByAppendingString:[NSString stringWithFormat:@"%@", d[k][@"EstimatedRunTime"]
                                                                         [all_backends[i]]]];
          estimateds = [estimateds stringByAppendingString:@", "];
        } else {
          estimateds = [estimateds
              stringByAppendingString:[NSString stringWithFormat:@"%@", d[k][@"EstimatedRunTime"]
                                                                         [all_backends[i]]]];
        }
      } else {
        estimateds = [estimateds stringByAppendingString:@", "];
      }

      if ([validation_messages containsObject:all_backends[i]]) {
        if (i < (max_backends - 1)) {
          error_messages = [error_messages
              stringByAppendingString:[NSString stringWithFormat:@"%@", d[k][@"ValidationMessages"]
                                                                         [all_backends[i]]]];
          error_messages = [error_messages stringByAppendingString:@", "];
        } else {
          error_messages = [error_messages stringByAppendingString:@", "];
        }
      } else {
        if (i < (max_backends - 1)) {
          error_messages = [error_messages stringByAppendingString:@", "];
        }
      }
    }

    // NSLog(@"%@", backends);
    // NSLog(@"%@", estimateds);
    // NSLog(@"%@", error_messages);
    NSLog(@"%@, %@, %@, %@, %@, %@", d[k][@"DebugName"], d[k][@"OpType"], d[k][@"SelectedBackend"],
          backends, estimateds, error_messages);
  }
}

int main(int argc, char *argv[]) {
  char *coreml_model_file;
  const char *mobilenet = "/tmp/MobileNet.mlmodelc";

  if (argc < 2) {
    coreml_model_file = (char *)mobilenet;
  } else {
    coreml_model_file = argv[1];
  }

  NSURL *testURL = [NSURL fileURLWithPath:[NSString stringWithUTF8String:coreml_model_file]];
  // NSLog(@"the mlmodelc directory: %@ ", [testURL absoluteURL]);

  profile_it(testURL);

  exit(0);
}
