//
//  YYGNavBarViewModel.h
//  Ledgerka
//
//  Created by Yan Gerasimuk on 20.04.2026.
//  Copyright © 2026 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YYGNavBarButtonViewModel;

NS_ASSUME_NONNULL_BEGIN

@interface YYGNavBarViewModel : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong, nullable) NSString *backButtonTitle;
@property (nonatomic, strong, nullable) YYGNavBarButtonViewModel *rightButtonViewModel;

- (instancetype)initWithTitle:(NSString * _Nonnull)title
              backButtonTitle:(NSString * _Nullable)backButtonTitle
         rightButtonViewModel:(YYGNavBarButtonViewModel * _Nullable)rightButtonViewModel;
@end

NS_ASSUME_NONNULL_END
