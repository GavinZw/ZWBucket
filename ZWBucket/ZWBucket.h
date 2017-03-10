//
//  ZWBucket.h
//  ZWBucket
//
//  Created by Gavin on 17/3/10.
//  Copyright © 2017年 Gavin. All rights reserved.
//

/**
 *  Leveldb是一个google实现的非常高效的kv数据库，目前能够支持billion级别的数据量了。
 *  在这个数量级别下还有着非常高的性能，主要归功于它的良好的设计.
 *  Leveldb是Jeff Dean和Sanjay Ghemawat两位大神级别的工程师发起的开源项目。其它更多更关Leveldb的介绍，可以google详细了解。
 *  Leveldb的项目托管在https://code.google.com/p/leveldb/
 */

#import <Foundation/Foundation.h>

//! Project version number for ZWBucket.
FOUNDATION_EXPORT double ZWBucketVersionNumber;

//! Project version string for ZWBucket.
FOUNDATION_EXPORT const unsigned char ZWBucketVersionString[];
#import <ZWBucket/ZWBucket.h>


/**
 *  Key-Value DB
 *  An Objective-C database library built over Google's LevelDB
 */
@interface ZWBucket : NSObject

/**
 *  Returns the singleton `ZWBucket`.
 *  The instance is used by `ZWBucket` class methods.
 */
@property (class, nonatomic, strong, readonly) ZWBucket *userDefault;

/**
  Initialize a leveldb instance

 @param name the filename of the database file on disk
 @param encrypt  is encryption
 */
- (instancetype)initWithName:(NSString *)name encrypt:(BOOL)encrypt;

/**
   name the filename of the database file on disk
 */
@property (nonatomic, copy, readonly) NSString *name;

#pragma mark -
#pragma mark - Memory Cache

+ (void)setObjectToMemory:(id)object forKey:(NSString *)key;
+ (id)objectFromMemoryForkey:(NSString *)key;
+ (void)removeObjectFromMemoryForKey:(NSString *)key;

#pragma mark -
#pragma mark - LocalCache

/**
 @warning By default, any object you store will be encoded and decoded using NSKeyedArchiver/NSKeyedUnarchiver.
 @warning   aItem needs to implement NSCoding serialization
 *          'ZWModel'can also be converted into dictionary storage.
 */
- (void)setItem:(id)aItem forKey:(NSString *)key;
- (id)itemForKey:(NSString *)key;
- (void)removeItemForKey:(NSString *)key;


/**
 * shortcuts
 
 ----
 use : ins.set(key, item)
 use : id val = ins.get(key)
 use : int.rm(key)
 ----
 */
@property (nonatomic, readonly) void(^set)(NSString *k, id item);
@property (nonatomic, readonly) id(^get)(NSString *key);
@property (nonatomic, readonly) void(^rm)(NSString *key);

/**
 * A boolean value indicating whether the database is closed or not.
 */
- (BOOL)close;

@end




