//
//  YGTools.m
//  Ledger
//
//  Created by Ян on 31/05/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGTools.h"
#import "YGConfig.h"
#import "YYGLedgerDefine.h"
#import <UIKit/UIKit.h>

#define kFileSizeAcronyms @[@"B", @"KB", @"MB", @"GB", @"TB"]

@implementation YGTools

#pragma mark - Date tools

+ (BOOL) isDayOfDate:(NSDate *)sourceDate equalsDayOfDate:(NSDate *)targetDate {
    
    NSDateComponents *dayOfSourceDate = [[NSCalendar currentCalendar] components:NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:sourceDate];
    
    NSDateComponents *dayOfTargetDate = [[NSCalendar currentCalendar] components:NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:targetDate];
    
    if([dayOfSourceDate day] == [dayOfTargetDate day] &&
       [dayOfSourceDate month] == [dayOfTargetDate month] &&
       [dayOfSourceDate year] == [dayOfTargetDate year] &&
       [dayOfSourceDate era] == [dayOfTargetDate era]) {
        
        return YES;
    }
    else
        return NO;
}

/**
 Problem: NSDate store only absolute time, without timezone.
 
 @"2017-08-13 00:49:33 +0300"
 */
+ (NSDate *) dayOfDate:(NSDate *)date {
    
    /*
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [calendar components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:date];
    
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    components.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    
    NSDate *newDate = [calendar dateFromComponents:components];
     */
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:kDateTimeFormat];
    
    NSString *stringDate = [formatter stringFromDate:date];
    stringDate = [stringDate stringByReplacingCharactersInRange:NSMakeRange(11, 14) withString:@"00:00:00 +0000"];
    
    return [formatter dateFromString:stringDate];
    
}

+ (NSString *) humanViewOfDate:(NSDate *)date {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ru_RU"]];
    [formatter setDateStyle:NSDateFormatterLongStyle];
    
    NSString *resultString = [formatter stringFromDate:date];
    
    return resultString;
}

+ (NSString *) humanViewWithTodayOfDate:(NSDate *)date {
    
    NSDateComponents *today = [[NSCalendar currentCalendar] components:NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
    
    NSDateComponents *otherDay = [[NSCalendar currentCalendar] components:NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];

    if([today day] == [otherDay day] &&
       [today month] == [otherDay month] &&
       [today year] == [otherDay year] &&
       [today era] == [otherDay era]) {
        
        return NSLocalizedString(@"TODAY", @"Today date");
    }
    else
        return [YGTools humanViewOfDate:date];
}

/**
 @warning Для даты с текущей русской локалью, в конце добавляется " г."
 */
+ (NSString *)stringHumanViewDMYOfDate:(NSDate *)date {
    
    NSString *resultString;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"d MMMM yyyy"];
    
    if([[[NSLocale currentLocale] localeIdentifier] hasPrefix:@"ru"])
        resultString = [NSString stringWithFormat:@"%@ г.", [formatter stringFromDate:date]];
    else
        resultString = [formatter stringFromDate:date];
    
    return resultString;
}


+ (NSString *)humanViewShortWithTodayOfDay:(NSDate *)day {
    
    NSString *resultDateString = nil;
    
    // get nsdate object
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:kDateTimeFormat];
    
    NSDateComponents *todayComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
    
    NSDateComponents *dayComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay  | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:day];
    
    
    if([todayComponents day] == [dayComponents day] &&
       [todayComponents month] == [dayComponents month] &&
       [todayComponents year] == [dayComponents year] &&
       [todayComponents era] == [dayComponents era]) {
        
        resultDateString = NSLocalizedString(@"TODAY", @"Today date");
    }
    else if(([todayComponents day] - [dayComponents day]) == 1 &&
            [todayComponents month] == [dayComponents month] &&
            [todayComponents year] == [dayComponents year] &&
            [todayComponents era] == [dayComponents era]) {
        
        resultDateString = NSLocalizedString(@"YESTERDAY", @"Yesterday date");
    } else {
        
        BOOL isSameYear = NO;
        
        if([todayComponents year] == [dayComponents year] &&
           [todayComponents era] == [dayComponents era]) {
            isSameYear = YES;
        }
        
        NSDateFormatter *formatterLocale = [[NSDateFormatter alloc] init];
        [formatterLocale setLocale:[NSLocale currentLocale]];
        
        if(isSameYear) {
            if([[[NSLocale currentLocale] localeIdentifier] hasPrefix:@"en"])
                [formatterLocale setDateFormat:@"MMMM d"];
            else
                [formatterLocale setDateFormat:@"d MMMM"];
        } else
            [formatterLocale setDateStyle:NSDateFormatterLongStyle];
        
        resultDateString = [formatterLocale stringFromDate:day];
    }
    
    return resultDateString;
}

/**
 Return given date string in human view.
 
 @param dateString String with date in format @"yyyy-MM-dd HH:mm:ss Z", for example: 2017-07-07 20:53:23 +0300.
 
 @return String with date in human view. For example: Today, 15:06; June 17, 11:11; January 17, 2017, 11:15.
 */
+ (NSString *)humanViewShortWithTodayOfDateString:(NSString *)dateString {
        
    NSString *resultDateString = nil;
    
    // 2017-07-07 20:53:23 +0300 -> 2017-07-07 20:53:23 +0000
    //dateString = [dateString stringByReplacingCharactersInRange:NSMakeRange(20,5) withString:@"+0000"];

    // get nsdate object
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:kDateTimeFormat];
    NSDate *date = [formatter dateFromString:dateString];
    
    NSDateComponents *today = [[NSCalendar currentCalendar] components:NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
    
    NSDateComponents *day = [[NSCalendar currentCalendar] components:NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay  | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:date];

    if([today day] == [day day] &&
       [today month] == [day month] &&
       [today year] == [day year] &&
       [today era] == [day era]) {
        
        resultDateString = NSLocalizedString(@"TODAY", @"Today date");
    }
    else if(([today day] - [day day]) == 1 &&
            [today month] == [day month] &&
            [today year] == [day year] &&
            [today era] == [day era]) {
        
        resultDateString = NSLocalizedString(@"YESTERDAY", @"Yesterday date");
    } else {
        BOOL isSameYear = NO;
        
        if([today year] == [day year] &&
           [today era] == [day era]) {
            isSameYear = YES;
        }
        
        NSDate *dateLong = [formatter dateFromString:dateString];
        
        NSDateFormatter *formatterLocale = [[NSDateFormatter alloc] init];
        [formatterLocale setLocale:[NSLocale currentLocale]];
        
        if(isSameYear) {
            if([[[NSLocale currentLocale] localeIdentifier] hasPrefix:@"en"])
                [formatterLocale setDateFormat:@"MMMM d"];
            else
                [formatterLocale setDateFormat:@"d MMMM"];
        } else
            [formatterLocale setDateStyle:NSDateFormatterLongStyle];
        
        resultDateString = [formatterLocale stringFromDate:dateLong];
    }
    
    NSDateFormatter *formatterTime = [[NSDateFormatter alloc] init];
    [formatterTime setDateFormat:kDateTimeFormatOnlyTime];
    NSString *timeString = [formatterTime stringFromDate:date];

    return [NSString stringWithFormat:@"%@, %@", resultDateString, timeString];
}

+ (NSString *)stringFromDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:kDateTimeFormat];
    
    return [formatter stringFromDate:date];
}

+ (NSString *)stringFromAbsoluteDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [formatter setDateFormat:kDateTimeFormat];
    
    return [formatter stringFromDate:date];
}

+ (NSString *)stringFromLocalDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    [formatter setDateFormat:kDateTimeFormat];
    
    return [formatter stringFromDate:date];
}

/**
 Using in format sql queries in Manager files.
 @warning Return string without quotes!
 */
+ (NSString *)stringWithCurrentTimeZoneFromDate:(NSDate *)date {
    @throw [NSException exceptionWithName:@"[YGTools stringWithCurrentTimeZoneFromDate:]" reason:@"Use another func!" userInfo:nil];
}

+ (NSDate *)dateFromString:(NSString *)string{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:kDateTimeFormat];
    
    return [formatter dateFromString:string];
}

+ (NSDate *)dateMinimum {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:kDateTimeFormat];
    
    return [formatter dateFromString:kDateMinimum];
}

#pragma mark - Value/classes to sql string

/**
 Return quoted string for update operations.
 @warning In insert operation we need unquoted strings! Don't use this method!
 */
+ (NSString *)sqlStringForDateLocalOrNull:(NSDate *)dateValue {
    if(dateValue) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setTimeZone:[NSTimeZone localTimeZone]];
        [formatter setDateFormat:kDateTimeFormat];
        
        return [NSString stringWithFormat:@"'%@'", [formatter stringFromDate:dateValue]];
    }
    else
        return @"NULL";
}

+ (NSString *)sqlStringForDateAbsoluteOrNull:(NSDate *)dateValue {
    if(dateValue) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [formatter setDateFormat:kDateTimeFormat];
        
        return [NSString stringWithFormat:@"'%@'", [formatter stringFromDate:dateValue]];
    } else
        return @"NULL";
}

+ (NSString *)sqlStringForBool:(BOOL)boolValue {
    if(boolValue)
        return [NSString stringWithFormat:@"%d", 1];
    else
        return [NSString stringWithFormat:@"%d", 0];
}

+ (NSString *)sqlStringForInt:(NSInteger)intValue {
    return [NSString stringWithFormat:@"%ld", (long)intValue];
}

+ (NSString *)sqlStringForIntOrNull:(NSInteger)intValue {
    if(intValue != -1)
        return [NSString stringWithFormat:@"%ld", (long)intValue];
    else
        return @"NULL";
}

+ (NSString *)sqlStringForStringOrNull:(NSString *)stringValue {
    if(stringValue && ![stringValue isEqualToString:@""])
        return [NSString stringWithFormat:@"'%@'", stringValue];
    else
        return @"NULL";
}

+ (NSString *)sqlStringForStringNotNull:(NSString *)stringValue {

    if(stringValue && ![stringValue isEqualToString:@""])
        return [NSString stringWithFormat:@"'%@'", stringValue];
    else
        @throw [NSException exceptionWithName:@"+[YGTools sqlStringForStringNotNull" reason:@"The string value can not be nil" userInfo:nil];
}

+ (NSString *)sqlStringForDouble:(double)doubleValue {
    return [NSString stringWithFormat:@"%f", doubleValue];
}

+ (NSString *)sqlStringForDecimal:(double)doubleValue {
    return [NSString stringWithFormat:@"%.2f", doubleValue];
}

+ (NSString *)sqlStringForIntOrDefault:(NSInteger)intValue {
    if(intValue > 0 && intValue < 1000)
        return [NSString stringWithFormat:@"%ld", (long)intValue];
    else
        return @"100";
}

#pragma mark - Config object of app

+ (YGConfig *)config {
    NSString *documentsDirectory = [YGTools documentsDirectoryPath];
    YGConfig *config = [[YGConfig alloc] initWithPath:documentsDirectory name:kAppConfigName];
    
    return [config copy];
}

#pragma mark - Device specific methods

+ (NSString *)documentsDirectoryPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
                                                         NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return [documentsDirectory copy];
}

#pragma mark - Size

/**
 Transform size in bytes in more human view. 15560749240 -> | 15 GB.
 
 - size: directory contens size in bytes,
 
 - return: size in nice, usefull string - ~ 15 GB.
 */
+ (NSString *)humanViewStringForByteSize:(NSUInteger)size{
    NSString *resultString = @"";
    NSUInteger leadNum = 0, trailNum = 0, abbIndex = 0;
    
    // B, KB, MB, GB...
    NSArray *abbSize = kFileSizeAcronyms;
    
    NSMutableString *stringNum = [[NSMutableString alloc] init];
    
    do {
        if(size < 1024 && size != 0) {
            [stringNum insertString:[NSString stringWithFormat:@"%lu %@", (long)size, abbSize[abbIndex]] atIndex:0];
            break;
        } else {
            leadNum = size / 1024;
            trailNum = size % 1024;
            
            size = leadNum;
            
            abbIndex++;
        }
        
    } while(size > 0);
    
    if([stringNum compare:@""] != NSOrderedSame)
        resultString = [NSString stringWithFormat:@"~ %@", stringNum];
    else
        resultString = @"0 B";
    
    return resultString;
}

#pragma mark - Specific device tuning

/**
 Default font size depends from width of screen this device. If func can not get info about screen width of concrete device fot set to 18.
 
 @return Font size.
 */
+ (CGFloat)defaultFontSize {
    
    static CGFloat fontSize = 0.f;
    
    if(fontSize == 0.f) {
        CGFloat width = [YGTools deviceScreenWidth];
        if(width <= 320.f)
            fontSize = 18.f;
        else if(width > 320.f && width <= 375.f)
            fontSize = 20.f;
        else if(width > 375.f && width <= 414.f)
            fontSize = 21.f;
        else
            fontSize = 21.f;
    }
    return fontSize;
}

/**
 Get current device screen width in points.

 @return Screen width (in points).
 */
+ (CGFloat)deviceScreenWidth {
    
    static CGFloat width = 0.f;
    
    if(width == 0.f) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSNumber *defaultWidth = [userDefaults valueForKey:kDeviceScreenWidth];
        if(!defaultWidth)
            @throw [NSException exceptionWithName:@"YGTools deviceScreenWidth" reason:@"Can not get current device screen width from UserDefaults" userInfo:nil];
        
        width = (CGFloat)[defaultWidth doubleValue];
    }
    return width;
}

#pragma mark - Default colors for actions

+ (UIColor *)colorForActionDisable {
    return [UIColor lightGrayColor];
}

+ (UIColor *)colorForActionDeactivate {
    return [UIColor colorWithRed:0/255.f green:122/255.f blue:255/255.f alpha:1.f];
}

+ (UIColor *)colorForActionActivate {
    return [UIColor colorWithRed:113/255.f green:211/255.f blue:49/255.f alpha:1.f];
}

+ (UIColor *)colorForActionSaveAndAddNew {
    return [UIColor colorWithRed:0/255.f green:122/255.f blue:255/255.f alpha:1.f];
}

+ (UIColor *)colorForActionBackup {
    return [UIColor colorWithRed:0/255.f green:122/255.f blue:255/255.f alpha:1.f];
}

+ (UIColor *)colorForActionRestore {
    return [UIColor colorWithRed:113/255.f green:211/255.f blue:49/255.f alpha:1.f];
}

+ (UIColor *)colorForActionDelete{
    return [UIColor colorWithRed:255/255.f green:95/255.f blue:119/255.f alpha:1.f];
}

+ (UIColor *)colorRed {
    return [UIColor colorWithRed:209/255.f green:47/255.f blue:27/255.f alpha:1.f];
}

+ (UIColor *)colorGreen {
    return [UIColor colorWithRed:0/255.f green:132/255.f blue:0/255.f alpha:1.f];
}

#pragma mark - Localization

+ (NSString *)languageCodeSystem {
    NSString *languageCode = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    return languageCode;
}

+ (NSString *)languageCodeApplication {
    NSString *languageCode = [self languageCodeSystem];
    
    if([languageCode hasPrefix:@"ru"])
        return @"ru";
    else
        return @"en";
}

#pragma mark - Check text in textFields

+ (BOOL)isValidSumInSourceString:(NSString *)sourceString replacementString:(NSString *)replacementString range:(NSRange)range {
    
    // get result string
    NSString *resultString = [sourceString stringByReplacingCharactersInRange:range withString:replacementString];
    
    if(!resultString || [resultString length] == 0)
        return YES;
    
    // length of result string
    if([resultString length] > 13)
        return NO;
    
    // check if every symbol is valid
    static NSString *charactersValid = @"0123456789.,";
    
    for(int i = 0; i < [replacementString length]; i++) {
        unichar ch = [replacementString characterAtIndex:i];
        
        BOOL isCharValid = NO;
        
        for(int j = 0; j < [charactersValid length]; j++){
            unichar chValid = [charactersValid characterAtIndex:j];
            if(ch == chValid)
                isCharValid = YES;
        }
        
        if(!isCharValid)
            return NO;
    }
    
    // check dot and comma, divider must by only one
    int countDivider = 0;
    for(int i = 0; i < [resultString length]; i++) {
        if([resultString characterAtIndex:i] == '.')
            countDivider += 1;
    }
    
    if(countDivider > 1)
        return NO;
    
    // check comma must by only one
    for(int i = 0; i < [resultString length]; i++) {
        if([resultString characterAtIndex:i] == ',')
            countDivider += 1;
    }
    
    if(countDivider > 1)
        return NO;
    
    // define divider
    NSRange rangeDivider = [resultString rangeOfString:@"."];
    if(rangeDivider.location == NSNotFound)
        rangeDivider = [resultString rangeOfString:@","];
    
    // check how much digit must be after divider
    if(rangeDivider.location != NSNotFound) {
        if([resultString length] - (rangeDivider.location + 1) > 2)
            return NO;
    }
    
    // check for leading zero
    if([resultString length] > 0 && [resultString characterAtIndex:0] == '0')
        return NO;
    
    return YES;
}

+ (BOOL)isValidSumWithZeroInSourceString:(NSString *)sourceString replacementString:replacementString range:(NSRange)range {
    
    // get result string
    NSString *resultString = [sourceString stringByReplacingCharactersInRange:range withString:replacementString];
    
    if(!resultString || [resultString length] == 0)
        return YES;
    
    // length of result string
    if([resultString length] > 13)
        return NO;
    
    // check if every symbol is valid
    static NSString *charactersValid = @"0123456789.,";
    
    for(int i = 0; i < [replacementString length]; i++) {
        unichar ch = [replacementString characterAtIndex:i];
        
        BOOL isCharValid = NO;
        
        for(int j = 0; j < [charactersValid length]; j++) {
            unichar chValid = [charactersValid characterAtIndex:j];
            if(ch == chValid)
                isCharValid = YES;
        }
        
        if(!isCharValid)
            return NO;
    }
    
    // check dot and comma, divider must by only one
    
    int countDivider = 0;
    for(int i = 0; i < [resultString length]; i++) {
        if([resultString characterAtIndex:i] == '.')
            countDivider += 1;
    }
    
    if(countDivider > 1)
        return NO;
    
    // check comma must by only one
    
    for(int i = 0; i < [resultString length]; i++) {
        if([resultString characterAtIndex:i] == ',')
            countDivider += 1;
    }
    
    if(countDivider > 1)
        return NO;
    
    // define divider
    NSRange rangeDivider = [resultString rangeOfString:@"."];
    if(rangeDivider.location == NSNotFound)
        rangeDivider = [resultString rangeOfString:@","];
    
    
    // check how much digit must be after divider
    if(rangeDivider.location != NSNotFound) {
        
        if([resultString length] - (rangeDivider.location + 1) > 2)
            return NO;
    }
    
    // check for leading zero
    if([resultString length] >= 2
       && [resultString characterAtIndex:0] == '0'
       && [resultString characterAtIndex:1] == '0')
        return NO;
    
    return YES;
}

+ (BOOL)isValidSortInSourceString:(NSString *)sourceString replacementString:(NSString *)replacementString range:(NSRange)range {
    
    // get result string
    NSString *resultString = [sourceString stringByReplacingCharactersInRange:range withString:replacementString];
    
    if(!resultString || [resultString length] == 0)
        return YES;
    
    // length of result string
    if([resultString length] > 3)
        return NO;
    
    // check if every symbol is valid
    static NSString *charactersValid = @"0123456789";
    
    for(int i = 0; i < [replacementString length]; i++) {
        unichar ch = [replacementString characterAtIndex:i];
        
        BOOL isCharValid = NO;
        
        for(int j = 0; j < [charactersValid length]; j++) {
            unichar chValid = [charactersValid characterAtIndex:j];
            if(ch == chValid)
                isCharValid = YES;
        }
        
        if(!isCharValid)
            return NO;
    }
    
    // chek for int value
    int intValue = [resultString intValue];
    if(intValue < 1 || intValue > 999)
        return NO;
    
    // check for leading zero
    if([resultString length] > 0 && [resultString characterAtIndex:0] == '0')
        return NO;
    
    return YES;
}

+ (BOOL)isValidCommentInSourceString:(NSString *)sourceString replacementString:replacementString range:(NSRange)range {
    
    // get result string
    NSString *resultString = [sourceString stringByReplacingCharactersInRange:range withString:replacementString];
    
    if(!resultString || [resultString length] == 0)
        return YES;
    
    // length of result string
    if([resultString length] > 55)
        return NO;

    return YES;
}


+ (BOOL)isValidNameInSourceString:(NSString *)sourceString replacementString:replacementString range:(NSRange)range {
    
    // get result string
    NSString *resultString = [sourceString stringByReplacingCharactersInRange:range withString:replacementString];
    
    if(!resultString || [resultString length] == 0)
        return YES;
    
    // length of result string
    if([resultString length] > 30)
        return NO;
        
    return YES;
}

+ (BOOL)isValidShortNameInSourceString:(NSString *)sourceString replacementString:replacementString range:(NSRange)range {
    
    // get result string
    NSString *resultString = [sourceString stringByReplacingCharactersInRange:range withString:replacementString];
    
    if(!resultString || [resultString length] == 0)
        return YES;
    
    // length of result string
    if([resultString length] > 5)
        return NO;
    
    return YES;
}

+ (BOOL)isValidSymbolInSourceString:(NSString *)sourceString replacementString:replacementString range:(NSRange)range {
    
    // get result string
    NSString *resultString = [sourceString stringByReplacingCharactersInRange:range withString:replacementString];
    
    if(!resultString || [resultString length] == 0)
        return YES;
    
    // length of result string
    if([resultString length] > 1)
        return NO;
    
    return YES;
}


#pragma mark - Attributed string tor labels

/**
 Attributed string with default font size. Uses for labels text.
 
 @text String with text.
 
 @color Color of text.
 
 @return Attributed string with defined text, color and default font size.

 */
+ (NSAttributedString *)attributedStringWithText:(NSString *)text color:(UIColor *)color {
    
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:[YGTools defaultFontSize]],
                                 NSForegroundColorAttributeName:color
                                 };
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

#pragma mark - Currency methods

/**
 Currency string from double, with or without fraction.
 
 */
+ (NSString *)stringCurrencyFromDouble:(double)sum hideDecimalFraction:(BOOL)hideDecimalFraction {
    
    sum = round(sum * 100)/100; // 1234.5600
    NSString *string = [NSString stringWithFormat:@"%.2f", sum]; // @"1234.56"
    
    // split string on integer and fraction parts
    NSArray *array = [string componentsSeparatedByString:@"."];
    NSMutableString *integerString = [array[0] mutableCopy];
    
    if(sum < 0)
        integerString = [[integerString substringFromIndex:1] mutableCopy];
    
    NSString *fractionString = [array[1] mutableCopy];
    
    // get current locale separators
    NSString *decimalSeparator = [[NSLocale currentLocale] decimalSeparator];
    NSString *groupingSeparator = [[NSLocale currentLocale] groupingSeparator];
    
    // work with integer part
    if([integerString length] > 3) {
        for(int c = 0, i = 3; i < ([integerString length] - c); i += 3, c++) {
            [integerString insertString:groupingSeparator atIndex:([integerString length] - i - c)];
        }
    }
    
    if(sum < 0)
        [integerString insertString:@"- " atIndex:0];
    
    // in depends on fraction part
    if(hideDecimalFraction || [fractionString isEqualToString:@"00"])
        string = integerString;
    else
        string = [NSString stringWithFormat:@"%@%@%@", integerString, decimalSeparator, fractionString];

    return string;
}

/**
 Currency string for view/edit controllers, set in textFields.
 */
+ (NSString *)stringCurrencyFromDouble:(double)sum {
    
    NSString *string = [NSString stringWithFormat:@"%.2f", sum];
    
    // split string on integer and fraction parts
    NSArray *array = [string componentsSeparatedByString:@"."];
    NSString *integerString = array[0];
    NSString *fractionString = array[1];
    
    // get current locale separators
    NSString *decimalSeparator = [[NSLocale currentLocale] decimalSeparator];
    
    if([fractionString isEqualToString:@"00"])
        string = integerString;
    else
        string = [NSString stringWithFormat:@"%@%@%@", integerString, decimalSeparator, fractionString];
    
    return string;
}

+ (double)doubleFromStringCurrency:(NSString *)string {
    
    // get current locale separators
    NSString *localSeparator = [[NSLocale currentLocale] decimalSeparator];
    NSString *standartSeparator = @".";
    
    if([string length] > 1) {
        for(NSInteger i = ([string length] - 1); i >= 0; i--) {
            NSString *s = [string substringWithRange:NSMakeRange(i, 1)];
            
            if([s isEqualToString:localSeparator]) {
                string = [string stringByReplacingCharactersInRange:NSMakeRange(i, 1) withString:standartSeparator];
            }
        }
    }
            
    return round([string doubleValue] * 100.0)/100.0;
}

#pragma mark - Date day to string and back

+ (NSString *)stringFromDateDay:(NSDate *)date {
    @throw [NSException exceptionWithName:@"+[YGTools stringFromDateDay]" reason:@"Depricated method" userInfo:nil];
    
    return nil;
}

+ (NSDate *)dateFromStringDay:(NSString *)date {
    @throw [NSException exceptionWithName:@"+[YGTools dateFromStringDay]" reason:@"Depricated method" userInfo:nil];

    return nil;
}

+ (NSString *)stringNilIfEmpty:(NSString *)string {
    if([string isEqualToString:@""])
        return nil;
    else
        return string;
}

#pragma mark - Get visible size of string

/**
 Определение ширины в точках заданной строки на экране. 
 
 @warning Подразумевается, что строка будет занимать одну строку, если нужно определить ширину параграфа смотри закомментированный код.
 
 @string Строка для которой определяется её ширина на экране.
 
 @return Ширина строки.
 
 */
+ (NSInteger)widthForContentString:(NSString *)string {
    
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:[self defaultFontSize]]};
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:string attributes:attributes];
    
    CGSize textSize = [attrString size];
    
    return (NSInteger)textSize.width;
}

/**
 Получаем строку, которая вмещается в заданную ширину.
 
 @holdInWidth максимальная ширина, в которую необходимо вписать строку.
 
 @return Итоговая строка, которая может вместиться в заданную ширину.
 */
+ (NSString *)stringForContentString:(NSString *)string holdInWidth:(NSInteger)width {
    
    NSMutableString *resultString = [string mutableCopy];
    
    NSRange range = NSMakeRange([resultString length] - 1, 1);
    
    // расстояние целевой строки до максимальной границы определяется тремя точками
    // если не вмещается, начинаем сокращать по одному символу
    while([self widthForContentString:[NSString stringWithFormat:@"%@...", [resultString copy]]] > width) {
        
        [resultString deleteCharactersInRange:range];
        
        range.location--;
    }
    
    return [NSString stringWithFormat:@"%@...", [resultString copy]];
}

+ (UIViewController*)topViewController {
    return [YGTools topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

+ (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    }
    else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    }
    else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else
        return rootViewController;
}

+ (NSArray *)namesAtPath:(NSString *)path {
    
    NSArray *names = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    
    names = [fileManager contentsOfDirectoryAtPath:path error:&error];
    
    if(error)
        NSLog(@"Fail to get contents of directory. Error: %@", [error description]);
    
    return names;
}

@end
