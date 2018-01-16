//
//  CLBDatabaseHelper.h
//  ClickLab
//
//  Copyright © 2017 ClickLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLBDatabaseHelper : NSObject

@property (nonatomic, strong, readonly) NSString *databasePath;

+ (CLBDatabaseHelper *)getDatabaseHelper;
- (BOOL)createTables;
- (BOOL)dropTables;
- (BOOL)upgrade:(int)oldVersion newVersion:(int)newVersion;
- (BOOL)resetDB:(BOOL)deleteDB;
- (BOOL)deleteDB;

- (BOOL)addEvent:(NSString *)event;
- (NSMutableArray *)getEvents:(long long)upToId limit:(long long)limit;
- (int)getEventCount;
- (BOOL)removeEvents:(long long)maxId;
- (BOOL)removeEvent:(long long)eventId;
- (long long)getNthEventId:(long long)n;
- (BOOL)updateEvent:(NSString *)event eventId:(long long)eventId;

- (BOOL)insertOrReplaceKeyValue:(NSString *)key value:(NSString *)value;
- (BOOL)insertOrReplaceKeyLongValue:(NSString *)key value:(NSNumber *)value;
- (NSString *)getValue:(NSString *)key;
- (NSNumber *)getLongValue:(NSString *)key;

@end
