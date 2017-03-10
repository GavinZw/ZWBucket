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
  dispatch_queue_t _lvldb_bucker_queue;
  LevelDB *_ldb;
}

@property (nonatomic, strong) NSMutableDictionary *memory_ldb;

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
  self = [super init];
  if (self) {
     NSParameterAssert(name && ![name isEqualToString:@""]);
    _name = [name copy];
    _lvldb_bucker_queue = dispatch_queue_create("com.gavin.create_DB", DISPATCH_QUEUE_SERIAL);
    _memory_ldb = @{}.mutableCopy;
    
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
      
      dispatch_sync(_lvldb_bucker_queue, ^{
       _ldb = [[LevelDB alloc] initWithPath:dbPath name:_name andOptions:opts];
      });
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
    sc = ^id(NSString *k) {
      @autoreleasepool {
        return [self itemForKey:k];
      }
    };
  }
  return sc;
}

- (void (^)(NSString *, id))set {
  static void(^sc)();
  if (!sc) {
    sc = ^(NSString *k, id v) {
      @autoreleasepool {
         return [self setItem:v forKey:k];
      }
    };
  }
  return sc;
}

- (void (^)(NSString *))rm {
  static void(^sc)();
  if (!sc) {
    sc = ^(NSString *k) {
      @autoreleasepool {
        return [self removeItemForKey:k];
      }
    };
  }
  return sc;
}

#pragma mark -
#pragma mark - private func

#pragma mark -
#pragma mark - Memory Cache

+ (void)setObjectToMemory:(id)object forKey:(NSString *)key{
  NSParameterAssert(key && object);
  @synchronized (self) {
    if (object && key) {
      [self.userDefault.memory_ldb setObject:object forKey:key];
    }
  }
}

+ (id)objectFromMemoryForkey:(NSString *)key{
  NSParameterAssert(key);
  @synchronized (self){
    return [self.userDefault.memory_ldb objectForKey:key];
  }
}

+ (void)removeObjectFromMemoryForKey:(NSString *)key{
  NSParameterAssert(key);
  @synchronized (self){
    [self.userDefault.memory_ldb removeObjectForKey:key];
  }
}

#pragma mark -
#pragma mark - LocalCache

- (void)setItem:(id)aItem forKey:(NSString *)key {
  NSParameterAssert(aItem && key && ![key isEqualToString:@""]);
  dispatch_barrier_async(_lvldb_bucker_queue, ^{
    @autoreleasepool{
      [self->_ldb setObject:aItem forKey:key];
    }
  });
}

- (id)itemForKey:(NSString *)key {
  NSParameterAssert(key);
  __block id item = nil;
  dispatch_sync(_lvldb_bucker_queue, ^{
    @autoreleasepool{
      item = [self->_ldb objectForKey:key];
    }
  });
  return item;
}

- (void)removeItemForKey:(NSString *)key {
  NSParameterAssert(key);
  dispatch_barrier_async(_lvldb_bucker_queue, ^{
     @autoreleasepool{
      [self->_ldb removeObjectForKey:key];
     }
  });
}

- (BOOL)close{
  [_ldb close];
  [_ldb deleteDatabaseFromDisk];
  
  return _ldb.closed;
}

@end
