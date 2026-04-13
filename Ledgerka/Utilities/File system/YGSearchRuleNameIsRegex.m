//
//  YGSearchRuleNameIsRegex.m
//  YGFileSystem
//
//  Created by Ян on 02/05/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGSearchRuleNameIsRegex.h"


@interface YGSearchRuleNameIsRegex (){
    NSString *_pattern;
}

@end

@implementation YGSearchRuleNameIsRegex

- (instancetype)initWithPattern:(NSString *)pattern ruleType:(YGSearchRuleType)ruleType{
    self = [super initWithType:ruleType];
    if(self){
        _pattern = pattern;
    }
    return self;
}

- (instancetype)initWithPattern:(NSString *)pattern{
    return [self initWithPattern:pattern ruleType:YGSearchRuleTypeDirect];
}

- (NSString *) descriptionRule{
    return @"Rule for object name to confirm regex match";
}

/**
 */
- (BOOL) isConfirm:(YGFileSystemObject *)object{
        
    @try{
 
        NSError *error = nil;
        //NSString *pattern = @"^\\d{4}[-]\\d{2}[-]\\d{2}$"; //@"^\\d{4}[-]\\d{2}[-]\\d{2}.+$";
        NSRegularExpressionOptions regexOptions = NSRegularExpressionCaseInsensitive;
        NSMatchingOptions matchingOptions = NSMatchingReportProgress;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:_pattern options:regexOptions error:&error];
        
        if(error){
            printf("\nError! Cannot create regex-object. %s", [[error description] UTF8String]);
            return NO;
        }
        /*
        if ([regex numberOfMatchesInString:object.name options:matchingOptions range:NSMakeRange(0, 10)] <= 0)
            return NO;
         */
        if([regex numberOfMatchesInString:object.name options:matchingOptions range:NSMakeRange(0, [object.name length])] <= 0)
            return NO;
        
        return YES;
    }
    @catch(NSException *ex){
        printf("\nError! Can not check directory name rule. Exception: %s", [[ex description] UTF8String]);
        return NO;
    }
}

/*
- (NSString *)lastModified{
    
    
    NSError *error = nil;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDictionary *attr = [fm attributesOfItemAtPath:[NSString stringWithFormat:@"%@/%@", self.pathFull, kContentFileName] error:&error];
    
    if(error){
        printf("Error! Can not read file attributes");
    }
    
    NSString *dateStringFromFileSystem = [NSString stringWithFormat:@"%@", attr[NSFileModificationDate]];
    
    NSDateFormatter *formatterFromFileSystem = [[NSDateFormatter alloc] init];
    [formatterFromFileSystem setDateFormat:kContentFileDateFormat]; //2017-04-27 21:16:49 +0000
    NSDate *dateOnFileSystem = [formatterFromFileSystem dateFromString:dateStringFromFileSystem];
    
    NSDateFormatter *formatterToSitemap = [[NSDateFormatter alloc] init];
    [formatterToSitemap setDateFormat:kSitemapLastmodFormat];
    NSString *dateStringToSitemap = [formatterToSitemap stringFromDate:dateOnFileSystem];
    
    return dateStringToSitemap;
}
 */

@end
