//
//  YYGReportRepository.h
//  Ledgerka
//
//  Created by Ян on 08.03.2020.
//  Copyright © 2020 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYGReportRepositoryInput.h"

@protocol YYGReportRepositoryOutput;
//@protocol YYGLanguage;

//@class YYGReportManager;


NS_ASSUME_NONNULL_BEGIN


@interface YYGReportRepository : NSObject <YYGReportRepositoryInput>

@property (nonatomic, weak) id<YYGReportRepositoryOutput> output;

//- (instancetype)initWithLanguage:(id<YYGLanguage>)language;
//
//- (instancetype)initWithManager:(YYGReportManager *)manager
//                       language:(id<YYGLanguage>)language;

@end

NS_ASSUME_NONNULL_END
