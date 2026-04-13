//
//  YGTools.h
//  Ledger
//
//  Created by Ян on 31/05/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class YGConfig;

@interface YGTools : NSObject

+ (BOOL) isDayOfDate:(NSDate *)sourceDate equalsDayOfDate:(NSDate *)targetDate;
+ (NSDate *)dayOfDate:(NSDate *)date;
+ (NSString *)humanViewOfDate:(NSDate *)date;
+ (NSString *)stringHumanViewDMYOfDate:(NSDate *)date;
+ (NSString *)humanViewWithTodayOfDate:(NSDate *)date;
+ (NSString *)stringFromDate:(NSDate *)date;
+ (NSString *)stringFromAbsoluteDate:(NSDate *)date;
+ (NSString *)stringFromLocalDate:(NSDate *)date;
//+ (NSString *)stringWithCurrentTimeZoneFromDate:(NSDate *)date;
+ (NSDate *)dateFromString:(NSString *)string;

+ (NSString *)humanViewShortWithTodayOfDateString:(NSString *)dateString;
+ (NSString *)humanViewShortWithTodayOfDay:(NSDate *)day;

+ (NSDate *)dateMinimum;

+ (NSString *)sqlStringForDateLocalOrNull:(NSDate *)dateValue;
+ (NSString *)sqlStringForDateAbsoluteOrNull:(NSDate *)dateValue;
+ (NSString *)sqlStringForBool:(BOOL)boolValue;
+ (NSString *)sqlStringForInt:(NSInteger)intValue;
+ (NSString *)sqlStringForIntOrNull:(NSInteger)intValue;
+ (NSString *)sqlStringForIntOrDefault:(NSInteger)intValue;
+ (NSString *)sqlStringForStringOrNull:(NSString *)stringValue;
+ (NSString *)sqlStringForStringNotNull:(NSString *)stringValue;
+ (NSString *)sqlStringForDouble:(double)doubleValue;
+ (NSString *)sqlStringForDecimal:(double)doubleValue;

+ (YGConfig *)config;

+ (NSString *)documentsDirectoryPath;

+ (NSString *)humanViewStringForByteSize:(NSUInteger)size;

+ (CGFloat)defaultFontSize;

+ (CGFloat)deviceScreenWidth;

+ (UIColor *)colorForActionDisable;
+ (UIColor *)colorForActionDeactivate;
+ (UIColor *)colorForActionActivate;
+ (UIColor *)colorForActionSaveAndAddNew;
+ (UIColor *)colorForActionBackup;
+ (UIColor *)colorForActionRestore;
+ (UIColor *)colorForActionDelete;
+ (UIColor *)colorRed;
+ (UIColor *)colorGreen;

/// current laguage code
+ (NSString *)languageCodeSystem;
+ (NSString *)languageCodeApplication;

+ (BOOL)isValidSumInSourceString:(NSString *)sourceString replacementString:replacementString range:(NSRange)range;
+ (BOOL)isValidSumWithZeroInSourceString:(NSString *)sourceString replacementString:replacementString range:(NSRange)range;
+ (BOOL)isValidSortInSourceString:(NSString *)sourceString replacementString:replacementString range:(NSRange)range;
+ (BOOL)isValidCommentInSourceString:(NSString *)sourceString replacementString:replacementString range:(NSRange)range;
+ (BOOL)isValidNameInSourceString:(NSString *)sourceString replacementString:replacementString range:(NSRange)range;
+ (BOOL)isValidShortNameInSourceString:(NSString *)sourceString replacementString:replacementString range:(NSRange)range;
+ (BOOL)isValidSymbolInSourceString:(NSString *)sourceString replacementString:replacementString range:(NSRange)range;

+ (NSAttributedString *)attributedStringWithText:(NSString *)text color:(UIColor *)color;

+ (NSString *)stringCurrencyFromDouble:(double)sum hideDecimalFraction:(BOOL)hideDecimalFraction;
+ (NSString *)stringCurrencyFromDouble:(double)sum;
+ (double)doubleFromStringCurrency:(NSString *)string;

+ (NSString *)stringFromDateDay:(NSDate *)date;
+ (NSDate *)dateFromStringDay:(NSString *)date;

+ (NSString *)stringNilIfEmpty:(NSString *)string;

+ (NSInteger)widthForContentString:(NSString *)string;
+ (NSString *)stringForContentString:(NSString *)string holdInWidth:(NSInteger)width;

+ (UIViewController*)topViewController;

+ (NSArray *)namesAtPath:(NSString *)path;
@end
