//
//  YYGTwoTextsViewModel.h
//  Ledgerka
//
//  Created by Yan Gerasimuk on 28.04.2026.
//  Copyright © 2026 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YYGTwoTextsViewModel : NSObject

- (instancetype)initWithFirstText:(NSAttributedString * _Nonnull)firstText
                       secondText:(NSAttributedString * _Nullable)secondText;

@property(nonatomic, readonly, strong) NSAttributedString *firstText;
@property(nonatomic, readonly, strong) NSAttributedString *secondText;

@end

NS_ASSUME_NONNULL_END
