//
//  ZWModel.h
//  ZWBucket
//
//  Created by Gavin on 17/3/10.
//  Copyright © 2017年 Gavin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ZWModel/ZWModel.h>

@interface ZWModel : ZWBaseModel

@property (nonatomic, strong) NSData *data;

@property (nonatomic, copy) NSString *index;

@property (nonatomic, strong) NSNumber *number;

@end
