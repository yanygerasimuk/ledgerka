//
//  YYGDBConfig.m
//  Ledger
//
//  Created by Ян on 01/08/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YYGDBConfig.h"
#import "YGSQLite.h"
#import "YYGLedgerDefine.h"

@implementation YYGDBConfig

+ (void)setValue:(id)value forKey:(NSString *)key {
    
    if([self valueForKey:key]){
        [self updateConfigRowValue:value forKey:key];
    }
    else{
        [self addConfigRowValue:value forKey:key];
    }
}

+ (id)valueForKey:(NSString *)key {
    
    YGSQLite *sqlite = [YGSQLite sharedInstance];
    
    NSString *sqlQuery = [NSString stringWithFormat:@"SELECT type, value FROM config WHERE key='%@' LIMIT 1;", key];
    
    NSArray *arrRows = [sqlite selectWithSqlQuery:sqlQuery];
    
    if([arrRows count] != 1)
        return nil;
    
    NSString *type = nil;
    NSString *value = nil;
    
    for(NSArray *arr in arrRows){
        type = arr[0];
        value = arr[1];
    }
    
    if([type isEqualToString:@"NSString"])
        return value;
    else if([type isEqualToString:@"d"])
        return [NSNumber numberWithDouble:[value doubleValue]];
    else if([type isEqualToString:@"i"])
        return [NSNumber numberWithInt:[value intValue]];
    else
        return nil;
}

+ (void)addConfigRowValue:(id)value forKey:(NSString *)key {
    
    NSString *type = nil;
    if([value isKindOfClass:[NSString class]]){
        type = @"NSString";
    }
    else if([value isKindOfClass:[NSNumber class]]){
        if(strcmp([value objCType], @encode(int)) == 0){
            type = @"i";
        }
        else if(strcmp([value objCType], @encode(double)) == 0){
            type = @"d";
        }
    }
    
    @try {
        NSArray *arrConfigRow = [NSArray
                                 arrayWithObjects:type,
                                 key,
                                 value,
                                 nil];
        
        NSString *insertSQL = @"INSERT INTO config (type, key, value) VALUES (?, ?, ?);";
        
        YGSQLite *sqlite = [YGSQLite sharedInstance];
        [sqlite addRecord:arrConfigRow insertSQL:insertSQL];
    }
    @catch(NSException *ex){
        ;
    }

}

+ (void)updateConfigRowValue:(id)value forKey:(NSString *)key {
    
    NSString *type = nil;
    
    if([value isKindOfClass:[NSString class]]){
        type = @"NSString";
    }
    else if([value isKindOfClass:[NSNumber class]]){
        if(strcmp([value objCType], @encode(int)) == 0){
            type = @"i";
        }
        else if(strcmp([value objCType], @encode(double)) == 0){
            type = @"d";
        }
    }

    NSString *updateSQL = [NSString stringWithFormat:@"UPDATE config SET type='%@', value='%@' WHERE key='%@';", type, value, value];
    
    YGSQLite *sqlite = [YGSQLite sharedInstance];
    [sqlite execSQL:updateSQL];
}

@end
