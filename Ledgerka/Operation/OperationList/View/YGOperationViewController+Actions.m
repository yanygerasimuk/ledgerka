//
//  YGOperationViewController+Actions.m
//  Ledger
//
//  Created by Ян on 04.08.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YGOperationViewController+Actions.h"

@implementation YGOperationViewController (Actions)

- (void)actionSetDebt {
    YYGOperationEditController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"YYGOperationEditScene"];
    vc.viewModel = [YYGOperationEditViewModel viewModelWith:YGOperationTypeSetDebt];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionGiveDebt {
    YYGOperationEditController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"YYGOperationEditScene"];
    vc.viewModel = [YYGOperationEditViewModel viewModelWith:YGOperationTypeGiveDebt];
    vc.viewModel.allowDebtCurrencies = [self.permissionViewModel allowCurrenciesWith:YYGCounterpartyTypeDebtor];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionRepaymentDebt {
    YYGOperationEditController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"YYGOperationEditScene"];
    vc.viewModel = [YYGOperationEditViewModel viewModelWith:YGOperationTypeRepaymentDebt];
    vc.viewModel.allowDebtCurrencies = [self.permissionViewModel allowCurrenciesWith:YYGCounterpartyTypeDebtor];

    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionGetCredit {
    YYGOperationEditController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"YYGOperationEditScene"];
    vc.viewModel = [YYGOperationEditViewModel viewModelWith:YGOperationTypeGetCredit];
    vc.viewModel.allowDebtCurrencies = [self.permissionViewModel allowCurrenciesWith:YYGCounterpartyTypeCreditor];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionReturnCredit {
    YYGOperationEditController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"YYGOperationEditScene"];
    vc.viewModel = [YYGOperationEditViewModel viewModelWith:YGOperationTypeReturnCredit];
    vc.viewModel.allowDebtCurrencies = [self.permissionViewModel allowCurrenciesWith:YYGCounterpartyTypeCreditor];
    
    [self.navigationController pushViewController:vc animated:YES];
}

@end
