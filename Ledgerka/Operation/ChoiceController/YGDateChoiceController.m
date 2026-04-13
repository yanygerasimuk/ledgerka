//
//  YGDateChoiceController.m
//  Ledger
//
//  Created by Ян on 17/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGDateChoiceController.h"
#import "YGTools.h"

@interface YGDateChoiceController() {
    BOOL _isDateValueChanged;
    NSDate *_initDateValue;
}
@property (weak, nonatomic) IBOutlet UIDatePicker *datePickerDate;
- (IBAction)datePickerDateValueChanged:(UIDatePicker *)sender;
@end

@implementation YGDateChoiceController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *buttonDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed)];
    
    self.navigationItem.rightBarButtonItem = buttonDone;
    
    self.navigationItem.title = NSLocalizedString(@"DATE_CHOICE_FORM_TITLE", @"Title of date choice form.");
    
    if(self.sourceDate) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.datePickerDate.date = self.sourceDate;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.datePickerDate.date = [NSDate date];
    }
    
    _initDateValue = [YGTools dayOfDate:self.datePickerDate.date];
    
    // set min and max dates
    self.datePickerDate.minimumDate = [YGTools dateMinimum];
    self.datePickerDate.maximumDate = [NSDate date];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)doneButtonPressed {
    
    self.targetDate = self.datePickerDate.date;
    
    if(self.customer == YGDateChoiceСustomerExpense) {
        [self performSegueWithIdentifier:@"unwindFromDateChoiceToExpenseEdit" sender:self];
    }
    else if(self.customer == YGDateChoiceСustomerAccountActual) {
        [self performSegueWithIdentifier:@"unwindFromDateChoiceToAccountActualEdit" sender:self];
    }
    else if(self.customer == YGDateChoiceСustomerIncome) {
        [self performSegueWithIdentifier:@"unwindFromDateChoiceToIncomeEdit" sender:self];
    }
    else if(self.customer == YGDateChoiceСustomerTransfer) {
        [self performSegueWithIdentifier:@"unwindFromDateChoiceToTransferEdit" sender:self];
    }
    else if(self.customer == YGDateChoiceCustomerOperation) {
        [self performSegueWithIdentifier:@"unwindFromDateChoiceToOperationEdit" sender:self];
    }
    else
        @throw [NSException exceptionWithName:@"-[YGDateChoiceController doneButtonPressed" reason:@"Can not choose unwind segue" userInfo:nil];
}

#pragma mark - Monitoring?

- (IBAction)datePickerDateValueChanged:(UIDatePicker *)sender {
    
    NSDate *newDate = [YGTools dayOfDate:self.datePickerDate.date];
    
    if([newDate isEqualToDate:_initDateValue]) {
        _isDateValueChanged = NO;
    } else
        _isDateValueChanged = YES;
    
    [self changeDoneButtonEnable];
}

- (void)changeDoneButtonEnable {
    if(_isDateValueChanged)
        self.navigationItem.rightBarButtonItem.enabled = YES;
    else
        self.navigationItem.rightBarButtonItem.enabled = NO;
}

@end
