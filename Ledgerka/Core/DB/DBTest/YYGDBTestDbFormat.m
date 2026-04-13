//
//  YYGDBTestDbFormat.m
//  Ledger
//
//  Created by Ян on 30.06.18.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

// http://www.sqlite.org/draft/fileformat.html

#import "YYGDBTestDbFormat.h"

@implementation YYGDBTestDbFormat

- (instancetype)init {
    self = [super init];
    if (self){
        _rule = NSLocalizedString(@"DB_TEST_RULE_BACKUP_FILE_MUST_BE_SQLITE", @"Format of backup file must be sqlite.");
        _isContinue = NO;
    }
    return self;
}

-(BOOL)run {
    
    NSString *fullName = [_owner dbFileFullName];
    
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:fullName];
    
    NSData *first16Byte = [handle readDataOfLength:16];
    
    [handle closeFile];
    
    NSString *fileHeader = [[NSString alloc] initWithData:first16Byte encoding:NSASCIIStringEncoding];
    
    if ([fileHeader containsString:@"SQLite format"]){
        _message = NSLocalizedString(@"DB_TEST_BACKUP_IS_SQLITE_FILE", @"Backup file is sqlite db file.");
        return YES;
    } else {
        _message = NSLocalizedString(@"DB_TEST_BACKUP_IS_NOT_SQLITE_FILE", @"Backup file is not sqlite db file.");
        return NO;
    }
}

@end
