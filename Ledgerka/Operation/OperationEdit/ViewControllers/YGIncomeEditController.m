//
//  YGIncomeEditController.m
//  Ledger
//
//  Created by Ян on 22/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGIncomeEditController.h"
#import "YGDateChoiceController.h"
#import "YGAccountChoiceController.h"
#import "YGIncomeSourceChoiceController.h"
#import "YGEntityManager.h"
#import "YGCategoryManager.h"
#import "YGOperationManager.h"
#import "YGTools.h"
#import "YYGLedgerDefine.h"

@interface YGIncomeEditController () <UITextFieldDelegate, UITextViewDelegate> {
    
    NSDate *p_day;
    YGCategory *_incomeSource;
    YGEntity *_account;
    YGCategory *_currency;
    NSString *_comment;
    
    BOOL _isDateChanged;
    BOOL _isIncomeSourceChanged;
    BOOL _isAccountChanged;
    BOOL _isSumChanged;
    BOOL _isCommentChanged;
    
    NSDate *_initDateValue;
    YGCategory *_initIncomeSourceValue;
    YGEntity *_initAccountValue;
    double _initSumValue;
    NSString *_initCommentValue;
    
    YGCategoryManager *_cm;
    YGEntityManager *_em;
    YGOperationManager *_om;
}

@property (assign, nonatomic) double sum;

@property (weak, nonatomic) IBOutlet UILabel *labelDate;
@property (weak, nonatomic) IBOutlet UILabel *labelIncomeSource;
@property (weak, nonatomic) IBOutlet UILabel *labelAccount;
@property (weak, nonatomic) IBOutlet UILabel *labelSum;
@property (weak, nonatomic) IBOutlet UILabel *labelCurrency;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labelsController;

@property (weak, nonatomic) IBOutlet UITextField *textFieldSum;
@property (weak, nonatomic) IBOutlet UITextView *textViewComment;

@property (weak, nonatomic) IBOutlet UIButton *buttonDelete;
@property (weak, nonatomic) IBOutlet UIButton *buttonSaveAndAddNew;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttonsOfController;

@property (weak, nonatomic) IBOutlet UITableViewCell *cellIncomeSource;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellAccount;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellDelete;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellSaveAndAddNew;

- (IBAction)textFieldSumEditingChanged:(UITextField *)sender;
- (IBAction)buttonDeletePressed:(UIButton *)sender;
- (IBAction)buttonSaveAndAddNewPressed:(UIButton *)sender;
@end

@implementation YGIncomeEditController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _cm = [YGCategoryManager sharedInstance];
    _em = [YGEntityManager sharedInstance];
    _om = [YGOperationManager sharedInstance];
    
    if(self.isNewIncome) {
        
        // set date
        p_day = [YGTools dayOfDate:[NSDate date]];
        self.labelDate.text = [YGTools humanViewWithTodayOfDate:p_day];
        
        if([_cm countOfActiveCategoriesForType:YGCategoryTypeIncome] == 1) {
            _incomeSource = [_cm categoryOnTopForType:YGCategoryTypeIncome];
            self.labelIncomeSource.text = _incomeSource.name;
            self.labelIncomeSource.textColor = [UIColor grayColor];
            
            self.cellIncomeSource.userInteractionEnabled = NO;
            self.cellIncomeSource.accessoryType = UITableViewCellAccessoryNone;
        } else {
            self.labelIncomeSource.text = NSLocalizedString(@"SELECT_INCOME_SOURCE_LABEL", @"Select source");
            self.labelIncomeSource.textColor = [YGTools colorRed];
        }
        
        // set default account if it exist
        _account = [_em entityAttachedForType:YGEntityTypeAccount];
        if(_account) {
            _currency = [_cm categoryById:_account.currencyId type:YGCategoryTypeCurrency];

            self.labelAccount.text = _account.name;
            self.labelCurrency.text = [_currency shorterName];
        }
        if(!_account && [_em countOfActiveEntitiesOfType:YGEntityTypeAccount] == 1) {
            
            _account = [_em entityOnTopForType:YGEntityTypeAccount];
            
            self.labelAccount.text = _account.name;
            self.labelAccount.textColor = [UIColor grayColor];
            
            _currency = [_cm categoryById:_account.currencyId type:YGCategoryTypeCurrency];
            self.labelCurrency.text = [_currency shorterName];
            self.labelCurrency.textColor = [UIColor grayColor];
            
            self.cellAccount.userInteractionEnabled = NO;
            self.cellAccount.accessoryType = UITableViewCellAccessoryNone;
        }
        
        if(!_account) {
            self.labelAccount.text = NSLocalizedString(@"SELECT_ACCOUNT_LABEL", @"Select account");
            self.labelAccount.textColor = [YGTools colorRed];
            self.labelCurrency.text = @"?";
            self.labelCurrency.textColor = [YGTools colorRed];
        }
        
        // set label sum red
        self.labelSum.attributedText = [YGTools attributedStringWithText:[NSString stringWithFormat:@"%@", NSLocalizedString(@"SUM", @"Sum.")] color:[YGTools colorRed]];
        
        _comment = nil;
        // имитируем placeholder у textView
        self.textViewComment.text = NSLocalizedString(@"TEXT_VIEW_COMMENT_PLACEHOLDER", @"Placeholder for all textView for comments.");
        self.textViewComment.textColor = [UIColor lightGrayColor];
        self.textViewComment.delegate = self;
        
        // init
        _initDateValue = [p_day copy];
        _initIncomeSourceValue = nil;
        _initAccountValue = nil;
        _initSumValue = 0.0f;
        _initCommentValue = nil;
        
        // hide button delete
        //self.buttonDelete.enabled = NO;
        self.cellDelete.hidden = YES;
        
        // show button save and add new
        self.cellSaveAndAddNew.hidden = NO;
        self.buttonSaveAndAddNew.enabled = NO;
        self.buttonSaveAndAddNew.titleLabel.textColor = [UIColor whiteColor];
        self.buttonSaveAndAddNew.backgroundColor = [YGTools colorForActionDisable];
        
        // set focus on sum only for all modes
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kKeyboardAppearanceDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.textFieldSum becomeFirstResponder];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        });
    } else {
        // set date
        p_day = self.income.day;
        self.labelDate.text = [YGTools humanViewWithTodayOfDate:p_day];
        
        // set income source
        //_incomeSource = [_cm categoryById:self.income.sourceId];
        _incomeSource = [_cm categoryById:self.income.sourceId type:YGCategoryTypeIncome];
        self.labelIncomeSource.text = _incomeSource.name;
        
        if([_cm countOfActiveCategoriesForType:YGCategoryTypeIncome] == 1) {
            
            YGCategory *otherIncomeSource = [_cm categoryOnTopForType:YGCategoryTypeIncome];
            
            if([_incomeSource isEqual:otherIncomeSource]) {
                self.labelIncomeSource.textColor = [UIColor grayColor];
                self.cellIncomeSource.userInteractionEnabled = NO;
                self.cellIncomeSource.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        
        // set account
        _account = [_em entityById:self.income.targetId type:YGEntityTypeAccount];
        self.labelAccount.text = _account.name;
        
        if([_em countOfActiveEntitiesOfType:YGEntityTypeAccount] == 1) {
            self.labelAccount.textColor = [UIColor grayColor];
            self.cellAccount.userInteractionEnabled = NO;
            self.cellAccount.accessoryType = UITableViewCellAccessoryNone;
        }
        
        // set currency
        //_currency = [_cm categoryById:self.income.targetCurrencyId];
        _currency = [_cm categoryById:self.income.targetCurrencyId type:YGCategoryTypeCurrency];
        self.labelCurrency.text = [_currency shorterName];
        
        // set sum
        _sum = self.income.targetSum;
        //self.textFieldSum.text = [NSString stringWithFormat:@"%.2f", self.income.targetSum];
        self.textFieldSum.text = [YGTools stringCurrencyFromDouble:self.income.targetSum];
        
        // set comment
        _comment = self.income.comment;
        
        // если комментария нет, то имитируем placeholder
        if(_comment && ![_comment isEqualToString:@""]) {
            self.textViewComment.text = _comment;
            self.textViewComment.textColor = [UIColor blackColor];
        } else {
            self.textViewComment.text = NSLocalizedString(@"TEXT_VIEW_COMMENT_PLACEHOLDER", @"Placeholder for all textView for comments.");
            self.textViewComment.textColor = [UIColor lightGrayColor];
        }
        self.textViewComment.delegate = self;
        
        // init
        _initDateValue = [p_day copy];
        _initIncomeSourceValue = [_incomeSource copy];
        _initAccountValue = [_account copy];
        _initSumValue = _sum;
        _initCommentValue = [_comment copy];
        
        // save and add new button does not need
        self.cellSaveAndAddNew.hidden = YES;
        self.buttonSaveAndAddNew.enabled = NO;
        self.buttonSaveAndAddNew.hidden = YES;
        
        // delete button
        self.cellDelete.hidden = NO;
        self.buttonDelete.enabled = YES;
        self.buttonDelete.hidden = NO;
        self.buttonDelete.backgroundColor = [YGTools colorForActionDelete];
    }
    
    // button save
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed)];
    
    self.navigationItem.rightBarButtonItem = saveButton;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    // title
    self.navigationItem.title = NSLocalizedString(@"INCOME_EDIT_FORM_TITLE", @"Title of Income operation.");
    
    // set font size of labels
    for(UILabel *label in self.labelsController) {
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:[YGTools defaultFontSize]], NSForegroundColorAttributeName:label.textColor,
                                     };
        NSAttributedString *attributed = [[NSAttributedString alloc] initWithString:label.text attributes:attributes];
        label.attributedText = attributed;
    }
    
    // init state for monitor user changes
    _isDateChanged = NO;
    _isIncomeSourceChanged = NO;
    _isAccountChanged = NO;
    _isSumChanged = NO;
    _isCommentChanged = NO;
    
    self.textFieldSum.delegate = self;
    self.textViewComment.delegate = self;

    [self setDefaultFontForControls];
}


- (void)setDefaultFontForControls {
    
    // set font size of labels
    for(UILabel *label in self.labelsController) {
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:[YGTools defaultFontSize]], NSForegroundColorAttributeName:label.textColor,
                                     };
        NSAttributedString *attributed = [[NSAttributedString alloc] initWithString:label.text attributes:attributes];
        label.attributedText = attributed;
    }
    
    for(UIButton *button in self.buttonsOfController) {
        button.titleLabel.font = [UIFont boldSystemFontOfSize:[YGTools defaultFontSize]];
    }
    
    // set font size of textField and textView
    self.textFieldSum.font = [UIFont systemFontOfSize:[YGTools defaultFontSize]];
    self.textViewComment.font = [UIFont systemFontOfSize:[YGTools defaultFontSize]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate & UITextViewDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if([textField isEqual:self.textFieldSum])
        return [YGTools isValidSumInSourceString:textField.text replacementString:string range:range];
    else
        return NO;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([textView isEqual:self.textViewComment]) {
        return [YGTools isValidCommentInSourceString:textView.text replacementString:text range:range];
    }
    else
        return NO;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if([textView isEqual:self.textViewComment]) {
        if(textView.text && [textView.text isEqualToString:NSLocalizedString(@"TEXT_VIEW_COMMENT_PLACEHOLDER", @"Placeholder for all textView for comments.")]) {
            textView.text = @"";
            textView.textColor = [UIColor blackColor];
        }
    }
    
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if([textView isEqual:self.textViewComment]) {
        if(!textView.text || [textView.text isEqualToString:@""]) {
            textView.text = NSLocalizedString(@"TEXT_VIEW_COMMENT_PLACEHOLDER", @"Placeholder for all textView for comments.");
            textView.textColor = [UIColor lightGrayColor];
        }
    }
    
    [textView resignFirstResponder];
}

#pragma mark - Property sum setter

- (void)setSum:(double)sum {
    _sum = round(sum * 100.0)/100.0;
}

#pragma mark - Come back from other choice controllers

- (IBAction)unwindFromDateChoiceToIncomeEdit:(UIStoryboardSegue *)unwindSegue {
    
    YGDateChoiceController *vc = unwindSegue.sourceViewController;
    
    p_day = [YGTools dayOfDate:vc.targetDate];
    self.labelDate.attributedText = [YGTools attributedStringWithText:[YGTools humanViewWithTodayOfDate:p_day] color:[UIColor blackColor]];
    
    // date changed?
    if([YGTools isDayOfDate:p_day equalsDayOfDate:_initDateValue])
        _isDateChanged = NO;
    else
        _isDateChanged = YES;
    
    [self changeSaveButtonEnable];
}

- (IBAction)unwindFromIncomeSourceChoiceToIncomeEdit:(UIStoryboardSegue *)unwindSegue {
    
    YGIncomeSourceChoiceController *vc = unwindSegue.sourceViewController;
    
    YGCategory *newIncomeSource = vc.targetIncome;
    
    _incomeSource = newIncomeSource;
    self.labelIncomeSource.attributedText = [YGTools attributedStringWithText:_incomeSource.name color:[UIColor blackColor]];
    
    if([_incomeSource isEqual:_initIncomeSourceValue])
        _isIncomeSourceChanged = NO;
    else
        _isIncomeSourceChanged = YES;
    
    [self changeSaveButtonEnable];
}

- (IBAction)unwindFromAccountChoiceToIncomeEdit:(UIStoryboardSegue *)unwindSegue {
    
    YGAccountChoiceController *vc = unwindSegue.sourceViewController;
    
    _account = vc.targetAccount;
    self.labelAccount.attributedText = [YGTools attributedStringWithText:_account.name color:[UIColor blackColor]];
    
    // may be lazy?
    _currency = [_cm categoryById:_account.currencyId type:YGCategoryTypeCurrency];
    self.labelCurrency.attributedText = [YGTools attributedStringWithText:[_currency shorterName] color:[UIColor blackColor]];
    
    if([_account isEqual:_initAccountValue])
        _isAccountChanged = NO;
    else
        _isAccountChanged = YES;
    
    [self changeSaveButtonEnable];
}

- (BOOL) isEditControlsChanged {
    if(_isDateChanged)
        return YES;
    if(_isIncomeSourceChanged)
        return YES;
    if(_isAccountChanged)
        return YES;
    if(_isSumChanged)
        return YES;
    if(_isCommentChanged)
        return YES;
    
    return NO;
}

- (BOOL) isDataReadyForSave {
    if(!p_day)
        return NO;
    if(!_incomeSource)
        return NO;
    if(!_account)
        return NO;
    if(_sum <= 0)
        return NO;
    
    return YES;
}

#pragma mark - Change save button enable

- (void) changeSaveButtonEnable {
    
    if([self isEditControlsChanged] && [self isDataReadyForSave]) {
        
        self.navigationItem.rightBarButtonItem.enabled = YES;
        
        if(self.isNewIncome) {
            self.buttonSaveAndAddNew.enabled = YES;
            self.buttonSaveAndAddNew.titleLabel.textColor = [UIColor whiteColor];
            self.buttonSaveAndAddNew.backgroundColor = [YGTools colorForActionSaveAndAddNew];
        }
    } else {
        
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
        if(self.isNewIncome){
            self.buttonSaveAndAddNew.enabled = NO;
            self.buttonSaveAndAddNew.titleLabel.textColor = [UIColor whiteColor];
            self.buttonSaveAndAddNew.backgroundColor = [YGTools colorForActionDisable];
        }
    }
}

#pragma mark - Monitoring of controls changed

- (IBAction)textFieldSumEditingChanged:(UITextField *)sender {
    
    self.sum = [YGTools doubleFromStringCurrency:self.textFieldSum.text];
    
    if(_initSumValue == self.sum)
        _isSumChanged = NO;
    else
        _isSumChanged = YES;
    
    if(self.sum == 0.00f)
        self.labelSum.attributedText = [YGTools attributedStringWithText:[NSString stringWithFormat:@"%@", NSLocalizedString(@"SUM", @"Sum.")] color:[YGTools colorRed]];
    else
        self.labelSum.attributedText = [YGTools attributedStringWithText:[NSString stringWithFormat:@"%@", NSLocalizedString(@"SUM", @"Sum.")] color:[UIColor blackColor]];
    
    [self changeSaveButtonEnable];
}

- (void)textViewDidChange:(UITextView *)textView {
    
    if([textView isEqual:self.textViewComment]) {
        
        _comment = textView.text;
        
        if([_initCommentValue isEqualToString:_comment])
            _isCommentChanged = NO;
        else
            _isCommentChanged = YES;
        
        [self changeSaveButtonEnable];
    }
}

#pragma mark - Save and delete actions

- (void)saveButtonPressed {
    [self saveIncome];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)buttonSaveAndAddNewPressed:(UIButton *)sender {
    [self saveIncome];
    [self initUIForNewIncome];
}

- (void)initUIForNewIncome {
    
    // init
    _initDateValue = [p_day copy];
    _initAccountValue = [_account copy];
    _initIncomeSourceValue = [_incomeSource copy];
    _initSumValue = 0.0f;
    _initCommentValue = @"";
    
    // init state for monitor user changes
    _isDateChanged = NO;
    _isIncomeSourceChanged = NO;
    _isAccountChanged = NO;
    _isSumChanged = NO;
    _isCommentChanged = NO;
    
    // deactivate "Add" and "Save & add new" bottons
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.buttonSaveAndAddNew.enabled = NO;
    self.buttonSaveAndAddNew.backgroundColor = [YGTools colorForActionDisable];
    
    self.labelSum.textColor = [YGTools colorRed];
    
    // set focus on sum only for new element
    self.textFieldSum.text = @"";
    [self.textFieldSum becomeFirstResponder];
}

- (void)saveIncome {
    
    NSDate *now = [NSDate date];
    NSString *comment = [_comment stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if(self.isNewIncome) {
        YGOperation *income = [[YGOperation alloc]
                               initWithType:YGOperationTypeIncome
                               sourceId:_incomeSource.rowId
                               targetId:_account.rowId
                               sourceSum:_sum
                               sourceCurrencyId:_account.currencyId
                               targetSum:_sum
                               targetCurrencyId:_account.currencyId
                               day:[p_day copy]
                               created:[now copy]
                               modified:[now copy]
                               comment:comment];
        
        NSInteger operationId = [_om addOperation:income];
        income.rowId = operationId;
        
        // update sum of account
        [_em recalcSumOfAccount:[_account copy] forOperation:[income copy]];
    } else {
        
        YGOperation *oldIncome = [self.income copy];
        
        if(_isDateChanged)
            self.income.day = [p_day copy];
        if(_isIncomeSourceChanged) {
            self.income.sourceId = _incomeSource.rowId;
            self.income.sourceCurrencyId = _currency.rowId;
        }
        if(_isAccountChanged) {
            self.income.targetId = _account.rowId;
            self.income.targetCurrencyId = _currency.rowId;
        }
        if(_isSumChanged) {
            self.income.sourceSum = _sum;
            self.income.targetSum = _sum;
        }
        if(_isCommentChanged)
            self.income.comment = comment;
        
        self.income.modified = [NSDate date];
        
        [_om updateOperation:oldIncome withNew:[self.income copy]];
        
        // need to recalc?
        if(_isDateChanged || _isAccountChanged || _isSumChanged) {
            // recalc account
            [_em recalcSumOfAccount:[_account copy] forOperation:nil];

            // recalc of old account, if it changed
            if(_isAccountChanged)
                [_em recalcSumOfAccount:[_initAccountValue copy] forOperation:nil];
        }
    }
}

- (IBAction)buttonDeletePressed:(UIButton *)sender {
    [_om removeOperation:self.income];
    [_em recalcSumOfAccount:_account forOperation:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"segueFromIncomeEditToDateChoice"]) {
        YGDateChoiceController *vc = segue.destinationViewController;
        vc.sourceDate = p_day;
        vc.customer = YGDateChoiceСustomerIncome;
    }
    else if([segue.identifier isEqualToString:@"segueFromIncomeEditToIncomeSourceChoice"]) {
        YGIncomeSourceChoiceController *vc = segue.destinationViewController;
        vc.sourceIncome = _incomeSource;
        vc.customer = YGIncomeSourceChoiceСustomerIncome;
    }
    else if([segue.identifier isEqualToString:@"segueFromIncomeEditToAccountChoice"]) {
        YGAccountChoiceController *vc = segue.destinationViewController;
        vc.sourceAccount = _account;
        vc.customer = YGAccountChoiceCustomerIncome;
    }
}

#pragma mark - Data source methods to show/hide action cells

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    
    if (indexPath.section == 3 && indexPath.row == 1 && !self.isNewIncome)
        height = 0;
    else if (indexPath.section == 3 && indexPath.row == 0 && self.isNewIncome)
        height = 0;
    
    return height;
}

@end
