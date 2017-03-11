//
//  ViewController.m
//  ZWBucketExample
//
//  Created by Gavin on 17/3/10.
//  Copyright © 2017年 Gavin. All rights reserved.
//

#import "ViewController.h"
#import <ZWBucket/ZWBucket.h>

#import "ZWModel.h"

NSString *const kSkyLoggedUser = @"sky_logged_credential";

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  
  [self performSelector:@selector(testZWBucket) withObject:nil afterDelay:0.0f];
  
//  [ZWBucket.userDefault close];

  
}

- (void)testZWBucket{
 
  dispatch_async(dispatch_get_global_queue(0, 0), ^{
    [self testBucket:@"queue1"];
  });
  
  dispatch_async(dispatch_get_global_queue(0, 0), ^{
   [self testBucket:@"queue2"];
  });
  
  dispatch_async(dispatch_get_global_queue(0, 0), ^{
    [self testBucket:@"queue3"];
  });
  
  
  dispatch_async(dispatch_get_global_queue(0, 0), ^{
    [self testBucket:@"queue4"];
  });
}

- (void)testBucket:(NSString *)key{
  for (int i = 0; i < 1000000; i++) {
    @autoreleasepool {
      
      ZWModel *model = [ZWModel new];
      model.index = [NSString stringWithFormat:@"%@_%d",key,i];
      
      ZWBucket.userDefault.set(key,@{@"email":@"lovegavin@outlook.com",
                                                @"password":model});
      
      NSDictionary *user = ZWBucket.userDefault.get(key);
      
      ZWModel *res = user[@"password"];
      NSLog(@"***********get: %@",res.index);
      
      ZWBucket.userDefault.rm(key);
      NSLog(@"***********remove: %@",ZWBucket.userDefault.get(key));
      
      
//      ZWModel *model = [ZWModel new];
//      model.number = [NSNumber numberWithInt:i];
//      
//      ZWBucket.userDefault.set(kSkyLoggedUser,@{@"email":@"lovegavin@outlook.com",
//                                                @"password":model});
//      
//      NSDictionary *user = ZWBucket.userDefault.get(kSkyLoggedUser);
//      
//      ZWModel *res = user[@"password"];
//      NSLog(@"***********get: %@",res.number);
//      
//      ZWBucket.userDefault.rm(kSkyLoggedUser);
//      NSLog(@"***********remove: %@",ZWBucket.userDefault.get(kSkyLoggedUser));
    }
  }
}


- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}


@end
