//
//  YGOperationSectionManager.m
//  Ledger
//
//  Created by Ян on 04.06.18.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YGOperationSectionManager.h"
#import "YGOperationRow.h"
#import "YGOperationManager.h"
#import "YGEntityManager.h"
#import "YGCategoryManager.h"
#import "YGEntity.h"
#import "YGCategory.h"
#import "YGTools.h"
#import "YGConfig.h"

@interface YGOperationSectionManager () {
    YGCategoryManager *p_categoryManager;
    YGEntityManager *p_entityManager;
    YGOperationManager *p_operationManager;

    NSMutableArray <YGOperation *> *p_operations; // ранее был просто NSArray
    
    /// for quick search in sectionsFromExpenses
    NSMutableArray <NSDate *> *_dates;

    YGConfig *p_config;
    NSInteger p_widthView; // CGFloat?
    BOOL p_hideDecimalFraction;
}
@end

@implementation YGOperationSectionManager

static NSInteger const kWidthOfMarginIndents = 45;

#pragma mark - sharedInstanse & init

+ (instancetype)sharedInstance {
    static YGOperationSectionManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[YGOperationSectionManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if(self) {
        p_categoryManager = [YGCategoryManager sharedInstance];
        p_entityManager = [YGEntityManager sharedInstance];
        p_operationManager = [YGOperationManager sharedInstance];
        p_operationManager.sectionDelegate = self;
        
        p_config = [YGTools config];
        
        // width of view must be set befor calculate of strings
        p_widthView = (NSInteger)[UIScreen mainScreen].bounds.size.width;
        
        [self makeSections];
    }
    return self;
}

/**
 Called from constructor and from outside, when reload operation list
 */
- (void)makeSections {
#ifdef DEBUG_PERFORMANCE
    NSLog(@"YGOperationSectionManager.makeSections");
#endif
    
    p_operations = p_operationManager.operations; // ранее была копия NSArrays
    _sections = [[self sectionsFromOperations] mutableCopy];
    [self sortSectionsByDate];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:@"OperationSectionManagerMakeSectionsEvent" object:nil];

#ifdef DEBUG_PERFORMANCE
    NSLog(@"<< makeSections finished");
#endif
}

- (NSArray <YGOperationSection*>*)sectionsFromOperations {
    
    YGConfig *config = [YGTools config];
    p_hideDecimalFraction = [[config valueForKey:@"HideDecimalFractionInLists"] boolValue];
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    [p_operations enumerateObjectsUsingBlock:^(YGOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSDate *dayOfDate = [YGOperationSectionManager dayOfDate:obj.day];
        NSPredicate *datePredicate = [NSPredicate predicateWithFormat:@"date = %@", dayOfDate];
        NSArray *sectionsForDay = [result filteredArrayUsingPredicate:datePredicate];
        
        if([sectionsForDay count] > 1) {
            @throw [NSException exceptionWithName:@"-[YGSections sectionsFromOperations]" reason:@"More than one section for the date" userInfo:nil];
        }
        
        if([sectionsForDay count] == 1) { // section for day exists yet
            YGOperationSection *section = [sectionsForDay firstObject];
            YGOperationRow *row = [[YGOperationRow alloc] initWithOperation:obj];
            [self cacheRow:row];
            [section addOperationRow:row];
        } else { // section for day is not exists
            YGOperationRow *row = [[YGOperationRow alloc] initWithOperation:obj];
            [self cacheRow:row];
            NSMutableArray *rows = [[NSMutableArray alloc] initWithObjects:row, nil];
            YGOperationSection *newSection = [[YGOperationSection alloc] initWithDate:dayOfDate operationRows:rows];
            [result addObject:newSection];
        }
    }];
    return result;
}

+ (NSDate *)dayOfDate:(NSDate *)date {
    
    NSDateFormatter *formatterFromDate = [[NSDateFormatter alloc] init];
    [formatterFromDate setDateFormat:@"yyyy-MM-dd"];
    NSString *stringFromDate = [formatterFromDate stringFromDate:date];
    
    NSDateFormatter *formatterToDate = [[NSDateFormatter alloc] init];
    [formatterToDate setDateFormat:@"yyyy-MM-dd"];
    NSDate *dateFromString = [formatterToDate dateFromString:stringFromDate];
    
    return dateFromString;
}

#pragma mark - Sort sections

- (void)sortSectionsByDate {
#ifdef DEBUG_PERFORMANCE
    NSLog(@"YGOperationSectionMananger.sortSectionsByDate");
#endif
    
    [_sections sortUsingComparator:^NSComparisonResult(YGOperationSection *sec1, YGOperationSection *sec2){
        if([sec1.date compare: sec2.date] == NSOrderedDescending)
            return NSOrderedAscending;
        else if([sec1.date compare:sec2.date] == NSOrderedAscending)
            return NSOrderedDescending;
        else
            return NSOrderedSame; // :)
    }];
    
#ifdef DEBUG_PERFORMANCE
    NSLog(@"<< sortSectinsByDate finished");
#endif
}

#pragma mark - Prepare cache for operation row

- (void)cacheRow:(YGOperationRow *)row {
    
    if(row.operation.type == YGOperationTypeExpense) {
        
        YGCategory *sourceCurrency = [p_categoryManager categoryById:row.operation.sourceCurrencyId type:YGCategoryTypeCurrency];
        
        row.sourceSum = [NSString stringWithFormat:@"- %@ %@", [YGTools stringCurrencyFromDouble:row.operation.sourceSum hideDecimalFraction:p_hideDecimalFraction], [sourceCurrency shorterName]];
        
        YGCategory *expenseCategory = [p_categoryManager categoryById:row.operation.targetId type:YGCategoryTypeExpense];
        
        NSInteger widthSum = [YGTools widthForContentString:row.sourceSum];
        NSInteger widthName = [YGTools widthForContentString:expenseCategory.name];
        
        if(widthName > (p_widthView - widthSum - kWidthOfMarginIndents))
            row.target = [YGTools stringForContentString:expenseCategory.name holdInWidth:(p_widthView - widthSum - kWidthOfMarginIndents)];
        else
            row.target = expenseCategory.name;
        
    }
    else if(row.operation.type == YGOperationTypeIncome) {
        
        YGCategory *targetCurrency = [p_categoryManager categoryById:row.operation.targetCurrencyId type:YGCategoryTypeCurrency];
        row.targetSum = [NSString stringWithFormat:@"+ %@ %@", [YGTools stringCurrencyFromDouble:row.operation.targetSum hideDecimalFraction:p_hideDecimalFraction], [targetCurrency shorterName]];
        
        YGCategory *incomeSource = [p_categoryManager categoryById:row.operation.sourceId type:YGCategoryTypeIncome];
        
        NSInteger widthSum = [YGTools widthForContentString:row.targetSum];
        NSInteger widthName = [YGTools widthForContentString:incomeSource.name];
        
        if(widthName > (p_widthView - widthSum - kWidthOfMarginIndents))
            row.source = [YGTools stringForContentString:incomeSource.name holdInWidth:(p_widthView - widthSum - kWidthOfMarginIndents)];
        else
            row.source = incomeSource.name;
    }
    else if(row.operation.type == YGOperationTypeAccountActual) {
        
        YGCategory *targetCurrency = [p_categoryManager categoryById:row.operation.targetCurrencyId type:YGCategoryTypeCurrency];
        row.targetSum = [NSString stringWithFormat:@"= %@ %@", [YGTools stringCurrencyFromDouble:row.operation.targetSum hideDecimalFraction:p_hideDecimalFraction], [targetCurrency shorterName]];
        
        YGEntity *targetAccount = [p_entityManager entityById:row.operation.targetId type:YGEntityTypeAccount];
        
        NSInteger widthSum = [YGTools widthForContentString:row.targetSum];
        NSInteger widthName = [YGTools widthForContentString:targetAccount.name];
        
        if(widthName > (p_widthView - widthSum - kWidthOfMarginIndents))
            row.target = [YGTools stringForContentString:targetAccount.name holdInWidth:(p_widthView - widthSum - kWidthOfMarginIndents)];
        else
            row.target = targetAccount.name;
    }
    else if(row.operation.type == YGOperationTypeTransfer) {
        
        // source
        YGCategory *sourceCurrency = [p_categoryManager categoryById:row.operation.sourceCurrencyId type:YGCategoryTypeCurrency];
        row.sourceSum = [NSString stringWithFormat:@"- %@ %@", [YGTools stringCurrencyFromDouble:row.operation.sourceSum hideDecimalFraction:p_hideDecimalFraction], [sourceCurrency shorterName]];
        
        YGEntity *sourceAccount = [p_entityManager entityById:row.operation.sourceId type:YGEntityTypeAccount];
        
        NSInteger widthSourceSum = [YGTools widthForContentString:row.sourceSum];
        NSInteger widthSourceName = [YGTools widthForContentString:sourceAccount.name];
        
        if(widthSourceName > (p_widthView - widthSourceSum - kWidthOfMarginIndents))
            row.source = [YGTools stringForContentString:sourceAccount.name holdInWidth:(p_widthView - widthSourceSum - kWidthOfMarginIndents)];
        else
            row.source = sourceAccount.name;
        
        // target
        YGCategory *targetCurrency = [p_categoryManager categoryById:row.operation.targetCurrencyId type:YGCategoryTypeCurrency];
        row.targetSum = [NSString stringWithFormat:@"+ %@ %@", [YGTools stringCurrencyFromDouble:row.operation.targetSum hideDecimalFraction:p_hideDecimalFraction], [targetCurrency shorterName]];
        
        YGEntity *targetAccount = [p_entityManager entityById:row.operation.targetId type:YGEntityTypeAccount];
        
        NSInteger widthTargetSum = [YGTools widthForContentString:row.sourceSum];
        NSInteger widthTargetName = [YGTools widthForContentString:targetAccount.name];
        
        if(widthTargetName > (p_widthView - widthTargetSum - kWidthOfMarginIndents))
            row.target = [YGTools stringForContentString:targetAccount.name holdInWidth:(p_widthView - widthTargetSum - kWidthOfMarginIndents)];
        else
            row.target = targetAccount.name;
    }
    else if(row.operation.type == YGOperationTypeSetDebt) {
        
        YGCategory *targetCurrency = [p_categoryManager categoryById:row.operation.targetCurrencyId type:YGCategoryTypeCurrency];
        row.targetSum = [NSString stringWithFormat:@"= %@ %@", [YGTools stringCurrencyFromDouble:row.operation.targetSum hideDecimalFraction:p_hideDecimalFraction], [targetCurrency shorterName]];
        
        YGEntity *targetDebt = [p_entityManager entityById:row.operation.targetId type:YGEntityTypeDebt];
        
        NSInteger widthSum = [YGTools widthForContentString:row.targetSum];
        NSInteger widthName = [YGTools widthForContentString:targetDebt.name];
        
        if(widthName > (p_widthView - widthSum - kWidthOfMarginIndents))
            row.target = [YGTools stringForContentString:targetDebt.name holdInWidth:(p_widthView - widthSum - kWidthOfMarginIndents)];
        else
            row.target = targetDebt.name;
    }
    else if(row.operation.type == YGOperationTypeGiveDebt) {
        // Source
        YGEntity *sourceAccount = [p_entityManager entityById:row.operation.sourceId type:YGEntityTypeAccount];
        
        NSInteger widthSourceName = [YGTools widthForContentString:sourceAccount.name];
        NSInteger widthSourceSum = 0;
        if(row.sourceSum && [row.sourceSum length] > 0)
            widthSourceSum = [YGTools widthForContentString:row.sourceSum];
        
        if(widthSourceName > (p_widthView - widthSourceSum - kWidthOfMarginIndents))
            row.source = [YGTools stringForContentString:sourceAccount.name holdInWidth:(p_widthView - widthSourceSum - kWidthOfMarginIndents)];
        else
            row.source = sourceAccount.name;
        
        // Target
        YGCategory *targetCurrency = [p_categoryManager categoryById:row.operation.targetCurrencyId type:YGCategoryTypeCurrency];
        row.targetSum = [NSString stringWithFormat:@"÷ %@ %@", [YGTools stringCurrencyFromDouble:row.operation.targetSum hideDecimalFraction:p_hideDecimalFraction], [targetCurrency shorterName]];
        
        YGEntity *targetDebt = [p_entityManager entityById:row.operation.targetId type:YGEntityTypeDebt];
        
        NSInteger widthSum = [YGTools widthForContentString:row.targetSum];
        NSInteger widthName = [YGTools widthForContentString:targetDebt.name];
        
        if(widthName > (p_widthView - widthSum - kWidthOfMarginIndents))
            row.target = [YGTools stringForContentString:targetDebt.name holdInWidth:(p_widthView - widthSum - kWidthOfMarginIndents)];
        else
            row.target = targetDebt.name;
    }
    else if(row.operation.type == YGOperationTypeRepaymentDebt) {
        
        // Source
        YGEntity *sourceDebt = [p_entityManager entityById:row.operation.sourceId type:YGEntityTypeDebt];
        
        NSInteger widthSourceName = [YGTools widthForContentString:sourceDebt.name];
        NSInteger widthSourceSum = 0;
        if(row.sourceSum && [row.sourceSum length] > 0)
            widthSourceSum = [YGTools widthForContentString:row.sourceSum];
        
        if(widthSourceName > (p_widthView - widthSourceSum - kWidthOfMarginIndents))
            row.source = [YGTools stringForContentString:sourceDebt.name holdInWidth:(p_widthView - widthSourceSum - kWidthOfMarginIndents)];
        else
            row.source = sourceDebt.name;
        
        // Target
        YGCategory *targetCurrency = [p_categoryManager categoryById:row.operation.targetCurrencyId type:YGCategoryTypeCurrency];
        row.targetSum = [NSString stringWithFormat:@"∓ %@ %@", [YGTools stringCurrencyFromDouble:row.operation.targetSum hideDecimalFraction:p_hideDecimalFraction], [targetCurrency shorterName]];
        
        YGEntity *targetAccount = [p_entityManager entityById:row.operation.targetId type:YGEntityTypeAccount];
        
        NSInteger widthSum = [YGTools widthForContentString:row.targetSum];
        NSInteger widthName = [YGTools widthForContentString:targetAccount.name];
        
        if(widthName > (p_widthView - widthSum - kWidthOfMarginIndents))
            row.target = [YGTools stringForContentString:targetAccount.name holdInWidth:(p_widthView - widthSum - kWidthOfMarginIndents)];
        else
            row.target = targetAccount.name;
    }
    else if(row.operation.type == YGOperationTypeGetCredit) {
        // Source
        YGEntity *sourceDebt = [p_entityManager entityById:row.operation.sourceId type:YGEntityTypeDebt];
        
        NSInteger widthSourceName = [YGTools widthForContentString:sourceDebt.name];
        NSInteger widthSourceSum = 0;
        if(row.sourceSum && [row.sourceSum length] > 0)
            widthSourceSum = [YGTools widthForContentString:row.sourceSum];
        
        if(widthSourceName > (p_widthView - widthSourceSum - kWidthOfMarginIndents))
            row.source = [YGTools stringForContentString:sourceDebt.name holdInWidth:(p_widthView - widthSourceSum - kWidthOfMarginIndents)];
        else
            row.source = sourceDebt.name;
        
        // Target
        YGCategory *targetCurrency = [p_categoryManager categoryById:row.operation.targetCurrencyId type:YGCategoryTypeCurrency];
        row.targetSum = [NSString stringWithFormat:@"× %@ %@", [YGTools stringCurrencyFromDouble:row.operation.targetSum hideDecimalFraction:p_hideDecimalFraction], [targetCurrency shorterName]];
        
        YGEntity *targetAccount = [p_entityManager entityById:row.operation.targetId type:YGEntityTypeAccount];
        
        NSInteger widthSum = [YGTools widthForContentString:row.targetSum];
        NSInteger widthName = [YGTools widthForContentString:targetAccount.name];
        
        if(widthName > (p_widthView - widthSum - kWidthOfMarginIndents))
            row.target = [YGTools stringForContentString:targetAccount.name holdInWidth:(p_widthView - widthSum - kWidthOfMarginIndents)];
        else
            row.target = targetAccount.name;
    }
    else if(row.operation.type == YGOperationTypeReturnCredit) {
        // Source
        YGEntity *sourceAccount = [p_entityManager entityById:row.operation.sourceId type:YGEntityTypeAccount];
        
        NSInteger widthSourceName = [YGTools widthForContentString:sourceAccount.name];
        NSInteger widthSourceSum = 0;
        if(row.sourceSum && [row.sourceSum length] > 0)
            widthSourceSum = [YGTools widthForContentString:row.sourceSum];
        
        if(widthSourceName > (p_widthView - widthSourceSum - kWidthOfMarginIndents))
            row.source = [YGTools stringForContentString:sourceAccount.name holdInWidth:(p_widthView - widthSourceSum - kWidthOfMarginIndents)];
        else
            row.source = sourceAccount.name;
        
        // Target
        YGCategory *targetCurrency = [p_categoryManager categoryById:row.operation.targetCurrencyId type:YGCategoryTypeCurrency];
        row.targetSum = [NSString stringWithFormat:@"± %@ %@", [YGTools stringCurrencyFromDouble:row.operation.targetSum hideDecimalFraction:p_hideDecimalFraction], [targetCurrency shorterName]];
        
        YGEntity *targetDebt = [p_entityManager entityById:row.operation.targetId type:YGEntityTypeDebt];
        
        NSInteger widthSum = [YGTools widthForContentString:row.targetSum];
        NSInteger widthName = [YGTools widthForContentString:targetDebt.name];
        
        if(widthName > (p_widthView - widthSum - kWidthOfMarginIndents))
            row.target = [YGTools stringForContentString:targetDebt.name holdInWidth:(p_widthView - widthSum - kWidthOfMarginIndents)];
        else
            row.target = targetDebt.name;
    }
    else {
        @throw [NSException exceptionWithName:@"YGOperationSectionManager cacheRow: fails." reason:@"Unknown operation type." userInfo:nil];
    }
}

#pragma mark - OperationSectionProtocol

- (void)addOperation:(YGOperation *)operation {
    
    YGOperationRow *row = [[YGOperationRow alloc] initWithOperation:operation];
    [self cacheRow:row];
    
    // Находим секцию для операции, если нет - создаем и вставляем в список секций
    NSDate *day = [YGOperationSectionManager dayOfDate:operation.day];
    YGOperationSection *section = [self sectionWithDate:day];
    if (section) {
        [section addOperationRow:row];
    } else {
        NSMutableArray *arr = [[NSMutableArray alloc] initWithObjects:row, nil];
        [self addSection:[[YGOperationSection alloc] initWithDate:day operationRows:arr]];
    }    
}

- (void)updateOperation:(YGOperation *)oldOperation withNew:(YGOperation *)newOperation {
#ifndef FUNC_DEBUG
#define FUNC_DEBUG
#endif
    
#ifdef FUNC_DEBUG
    NSLog(@"YGOperationSectionMananger.updateOperation:withNew:");
    NSLog(@"oldOperation:\n%@", [oldOperation description]);
    NSLog(@"newOperation:\n%@", [newOperation description]);
#endif
    
    // New or exist section
    if ([oldOperation.day compare:newOperation.day] == NSOrderedSame) {
        YGOperationSection *section = [self sectionWithDate:oldOperation.day];

#ifdef FUNC_DEBUG
        NSLog(@"Day is not changed.");
        NSLog(@"Current section:\n%@", [section description]);
#endif
        
        NSMutableArray <YGOperationRow *> *rows = [section.operationRows mutableCopy];
        NSInteger index = [rows indexOfObjectPassingTest:^BOOL(YGOperationRow * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (oldOperation.rowId == obj.operation.rowId)
                return YES;
            else
                return NO;
        }];
        
#ifdef FUNC_DEBUG
        NSLog(@"Finded index in section.rows: %ld", (long)index);
        NSLog(@"Finded operation:\n%@", rows[index].operation);
#endif
        
        rows[index].operation = [newOperation copy];
        [self cacheRow:rows[index]];
        [section setOperationRows:rows];
    } else {
#ifdef FUNC_DEBUG
        NSLog(@"Day is changed.");
#endif
        [self removeOperation:oldOperation];
        [self addOperation:newOperation];
    }
}

- (void)removeOperation:(YGOperation *)operation {
    
    YGOperationSection *section = [self sectionWithDate:operation.day];
    
    // find index of operation
    NSInteger index = [section.operationRows indexOfObjectPassingTest:^BOOL(YGOperationRow * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (operation.rowId == obj.operation.rowId)
            return YES;
        else
            return NO;
    }];
    
    // temp mutableArray
    NSMutableArray <YGOperationRow *> *rows = [section.operationRows mutableCopy];
    [rows removeObjectAtIndex:index];
    
    // update section rows
    [section setOperationRows:rows];
    
    // remove section without rows
    if ([section.operationRows count] == 0) {
        NSInteger index = [_sections indexOfObject:section];
        [_sections removeObjectAtIndex:index];
    }
}

#pragma mark - Tools for update cache

- (YGOperationSection *)sectionWithDate:(NSDate *)date {
    // Need becouse date add +3 hours :)
    NSDate *day = [YGOperationSectionManager dayOfDate:date];
    NSPredicate *dayPredicate = [NSPredicate predicateWithFormat:@"date = %@", day];
    return [[self.sections filteredArrayUsingPredicate:dayPredicate] firstObject];
}

- (void)addSection:(YGOperationSection *)section {
#ifndef FUNC_DEBUG
#define FUNC_DEBUG
#endif

#ifdef FUNC_DEBUG
    NSLog(@"YGOperationSectionManager.addSection");
#endif
    
    // Calculate bounds for new section in dataSource
    NSInteger lowIndex = [self.sections indexOfObjectPassingTest:^BOOL(YGOperationSection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([section.date compare:obj.date] == NSOrderedAscending) {
            return YES;
        } else {
            return NO;
        }
    }];
    NSInteger upperIndex = [self.sections indexOfObjectPassingTest:^BOOL(YGOperationSection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([section.date compare:obj.date] == NSOrderedDescending) {
            return YES;
        } else {
            return NO;
        }
    }];
    
#ifdef FUNC_DEBUG
    NSLog(@"lowIndex: %ld, upperIndex: %ld", (long)lowIndex, (long)upperIndex);
#endif
    
    // Add new section to dataSource
    if (lowIndex != NSNotFound && upperIndex != NSNotFound) {
        [self.sections insertObject:section atIndex:upperIndex];
    } else if (lowIndex != NSNotFound && upperIndex == NSNotFound) {
        [self.sections addObject:section];
    } else if (lowIndex == NSNotFound && upperIndex != NSNotFound) {
        [self.sections insertObject:section atIndex:0];
    } else if (lowIndex == NSNotFound && upperIndex == NSNotFound) {
        [self.sections addObject:section];
    }
}

@end
