//
//  ZWBucket.m
//  ZWBucket
//
//  Created by Gavin on 17/3/10.
//  Copyright © 2017年 Gavin. All rights reserved.
//

#import <Objective-LevelDB/LevelDB.h>
#import "ZWBucket.h"

static NSString *const kDatabaseFilenName = @"com.gavin.userDefault";

@interface ZWBucket () {
  LevelDB *_ldb;
}

@end

@implementation ZWBucket

#pragma mark -
#pragma mark - shared instance

/**
 *  Returns the singleton `ZWBucket`.
 *  The instance is used by `ZWBucket` class methods.
 *
 *  @return The singleton `ZWBucket`.
 */
+ (instancetype)userDefault {
  static id sharedInstance = nil;
  
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[self alloc] initWithName:kDatabaseFilenName encrypt:NO];
  });
  
  return sharedInstance;
}

#pragma mark -
#pragma mark - lifecycle

- (instancetype)initWithName:(NSString *)name encrypt:(BOOL)encrypt{
  if (name.length == 0) return nil;
  self = [super init];
  if (self) {
    _name = [name copy];
    
    //db options
    LevelDBOptions opts = [LevelDB makeOptions];
    opts.createIfMissing = true;
    opts.errorIfExists = false;
    opts.paranoidCheck = false;
    opts.compression = true;
    opts.filterPolicy = 0;
    
    // make path
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES) firstObject];
    if (docPath) {
      NSString *dbFile = [_name stringByAppendingPathExtension:@"ldb"];
      NSString *dbPath = [docPath stringByAppendingPathComponent:dbFile];
      
       _ldb = [[LevelDB alloc] initWithPath:dbPath name:_name andOptions:opts];
      [_ldb removeAllObjects];
      
      _ldb.encoder = ^ NSData * (LevelDBKey *key, id object) {
        // return some data, given an object
        __block id result = nil;
        result = [NSKeyedArchiver archivedDataWithRootObject:object];
        return result;
      };
      _ldb.decoder = ^ id (LevelDBKey *key, NSData * data) {
        // return an object, given some data
        __block id result = nil;
        result = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        return result;
      };
    }
    
    else{
      @throw [NSException exceptionWithName:@"ZWBucketError"
                                     reason:@"can't find document path"
                                   userInfo:nil];
    }

    NSAssert(_ldb, @"create level db failed!");
  }
  
  return self;
}

#pragma mark -
#pragma mark - properties

- (id (^)(NSString *))get {
  static id(^sc)();
  if (!sc) {
     __weak typeof(self) _self = self;
    sc = ^id(NSString *k) {
      __strong typeof(_self) self = _self;
      return [self itemForKey:k];
    };
  }
  return sc;
}

- (void (^)(NSString *, id))set {
  static void(^sc)();
  if (!sc) {
    __weak typeof(self) _self = self;
    sc = ^(NSString *k, id v) {
      __strong typeof(_self) self = _self;
      return [self setItem:v forKey:k];
    };
  }
  return sc;
}

- (void (^)(NSString *))rm {
  static void(^sc)();
  if (!sc) {
     __weak typeof(self) _self = self;
    sc = ^(NSString *k) {
      __strong typeof(_self) self = _self;
      return [self removeItemForKey:k];
    };
  }
  return sc;
}

#pragma mark -
#pragma mark - private func

#pragma mark -
#pragma mark - public Cache

- (void)setItem:(id)aItem forKey:(NSString *)key {
  if (!key) return;
  dispatch_barrier_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    @autoreleasepool{
      [self->_ldb setObject:aItem forKey:key];
    }
  });
}

- (id)itemForKey:(NSString *)key {
  if (!key) return nil;
  __block id item = nil;
  dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    @autoreleasepool{
      item = [self->_ldb objectForKey:key];
    }
  });
  return item;
}

- (void)removeItemForKey:(NSString *)key {
  if (!key) return;
  dispatch_barrier_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
     @autoreleasepool{
      [self->_ldb removeObjectForKey:key];
     }
  });
}

- (BOOL)close{
  @synchronized (self) {
    [_ldb close];
    [_ldb deleteDatabaseFromDisk];
    return _ldb.closed;
  }
}

@end
