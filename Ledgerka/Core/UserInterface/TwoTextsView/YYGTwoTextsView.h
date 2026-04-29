//
//  YYGTwoTextsView.h
//  Ledgerka
//
//  Created by Yan Gerasimuk on 28.04.2026.
//  Copyright © 2026 Yan Gerasimuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYGTwoTextsViewModel.h"

NS_ASSUME_NONNULL_BEGIN


@interface YYGTwoTextsView : UIView

- (instancetype)initWithViewModel:(YYGTwoTextsViewModel *)viewModel;

- (void)configureWithViewModel:(YYGTwoTextsViewModel *)viewModel;

@end

NS_ASSUME_NONNULL_END
