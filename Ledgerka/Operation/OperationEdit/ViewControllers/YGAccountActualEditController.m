//
//  YGAccountActualEditController.m
//  Ledger
//
//  Created by Ян on 19/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGAccountActualEditController.h"
#import "YGDateChoiceController.h"
#import "YGAccountChoiceController.h"
#import "YGTools.h"
#import "YGEntityManager.h"
#import "YGCategoryManager.h"
#import "YGOperationManager.h"
#import "YYGLedgerDefine.h"

@interface YGAccountActualEditController () <UITextFieldDelegate, UITextViewDelegate> {
    
    NSDate *p_day;
    YGEntity *_account;
    YGCategory *_currency;
    double _sourceSum;
    double _targetSum;
    NSString *_comment;
    
    BOOL _isAccountChanged;
    BOOL _isSumChanged;
    BOOL _isCommentChanged;
    
    YGEntity *_initAccountValue;
    double _initSumValue;
    NSString *_initCommentValue;
    
    YGOperationManager *_om;
    YGCategoryManager *_cm;
    YGEntityManager *_em;
}
@property (assign, nonatomic) double sum;

@property (weak, nonatomic) IBOutlet UILabel *labelDate;
@property (weak, nonatomic) IBOutlet UILabel *labelAccount;
@property (weak, nonatomic) IBOutlet UILabel *labelActualTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelTargetCurrency;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labelsController;

@property (weak, nonatomic) IBOutlet UITextField *textFieldTargetSum;
@property (weak, nonatomic) IBOutlet UITextView *textViewComment;

@property (weak, nonatomic) IBOutlet UIButton *buttonDelete;
@property (weak, nonatomic) IBOutlet UIButton *buttonSaveAndAddNew;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttonsOfController;

- (IBAction)textFieldTargetSumEditingChanged:(UITextField *)sender;
- (IBAction)buttonDeletePressed:(UIButton *)sender;
- (IBAction)buttonSaveAndAddNewPressed:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UITableViewCell *cellDate;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellAccount;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellActualSum;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellComment;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellDelete;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellSaveAndAddNew;
@end

@implementation YGAccountActualEditController 

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _om = [YGOperationManager sharedInstance];
    _cm = [YGCategoryManager sharedInstance];
    _em = [YGEntityManager sharedInstance];
    
    if(self.isNewAccountAcutal) {
        
        // set date
        p_day = [YGTools dayOfDate:[NSDate date]];
        self.labelDate.text = [YGTools humanViewWithTodayOfDate:p_day];
        
        // set default account if it exist
        _account = [_em entityAttachedForType:YGEntityTypeAccount];
        
        if(_account) {
            _currency = [_cm categoryById:_account.currencyId type:YGCategoryTypeCurrency];
            self.labelAccount.text = _account.name;
            self.labelTargetCurrency.text = [_currency shorterName];
        }
        
        if(!_account && [_em countOfActiveEntitiesOfType:YGEntityTypeAccount] == 1) {
            
            _account = [_em entityOnTopForType:YGEntityTypeAccount];
            
            self.labelAccount.text = _account.name;
            self.labelAccount.textColor = [UIColor grayColor];
            
            _currency = [_cm categoryById:_account.currencyId type:YGCategoryTypeCurrency];
            self.labelTargetCurrency.text = [_currency shorterName];
            self.labelTargetCurrency.textColor = [UIColor grayColor];
            
            self.cellAccount.userInteractionEnabled = NO;
            self.cellAccount.accessoryType = UITableViewCellAccessoryNone;
        }
        
        if(!_account) {
            self.labelAccount.text = NSLocalizedString(@"SELECT_ACCOUNT_LABEL", @"Select account.");
            self.labelAccount.textColor = [YGTools colorRed]; //[UIColor redColor];
            self.labelTargetCurrency.text = @"?";
            self.labelTargetCurrency.textColor = [YGTools colorRed];
        }
        
        // set label sum red
        self.labelActualTitle.attributedText = [YGTools attributedStringWithText:[NSString stringWithFormat:@"%@", NSLocalizedString(@"SUM", @"Sum")] color:[YGTools colorRed]];
        
        // имитируем placeholder у textView
        self.textViewComment.text = NSLocalizedString(@"TEXT_VIEW_COMMENT_PLACEHOLDER", @"Placeholder for all textView for comments.");
        self.textViewComment.textColor = [UIColor lightGrayColor];
        self.textViewComment.delegate = self;
        
        // init
        _initAccountValue = nil;
        _initSumValue = -1.0f;
        _initCommentValue = nil;

        // button save
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed)];
        
        self.navigationItem.rightBarButtonItem = saveButton;
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
        // button delete disable
        self.buttonDelete.enabled = NO;
        self.buttonDelete.hidden = YES;
        
        // show button save and add new
        self.cellSaveAndAddNew.hidden = NO;
        self.buttonSaveAndAddNew.enabled = NO;
        self.buttonSaveAndAddNew.titleLabel.textColor = [UIColor whiteColor];
        self.buttonSaveAndAddNew.backgroundColor = [YGTools colorForActionDisable];
        
        // focus on sum only for new element        
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kKeyboardAppearanceDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.textFieldTargetSum becomeFirstResponder];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        });
    } else {
        // set date
        p_day = self.accountActual.day;
        self.labelDate.text = [YGTools humanViewWithTodayOfDate:p_day];
        
        // set account
        _account = [_em entityById:self.accountActual.sourceId type:YGEntityTypeAccount];
        self.labelAccount.text = _account.name;
        self.labelAccount.textColor = [UIColor grayColor];
        self.cellAccount.accessoryType = UITableViewCellAccessoryNone;
        self.cellAccount.userInteractionEnabled = NO;
        
        YGCategory *currency = [_cm categoryById:_account.currencyId type:YGCategoryTypeCurrency];
        _currency = currency;
        self.labelAccount.text = _account.name;
        self.labelTargetCurrency.text = [_currency shorterName];
        self.labelTargetCurrency.textColor = [UIColor grayColor];
        
        // set sum
        self.textFieldTargetSum.text = [YGTools stringCurrencyFromDouble:self.accountActual.targetSum];
        
        self.textFieldTargetSum.enabled = NO;
        self.textFieldTargetSum.textColor = [UIColor grayColor];
        self.labelActualTitle.textColor = [UIColor grayColor];
        self.cellActualSum.userInteractionEnabled = NO;
        
        // set comment
        _comment = self.accountActual.comment;
        
        // если комментария нет, то имитируем placeholder
        if(_comment && ![_comment isEqualToString:@""])
            self.textViewComment.text = _comment;
        else
            self.textViewComment.text = NSLocalizedString(@"TEXT_VIEW_COMMENT_PLACEHOLDER", @"Placeholder for all textView for comments.");
        
        self.textViewComment.textColor = [UIColor lightGrayColor];
        self.cellComment.userInteractionEnabled = NO;
        
        // init
        _initAccountValue = [_account copy];
        _initSumValue = _targetSum;
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
    
    // title
    self.navigationItem.title = NSLocalizedString(@"BALANCE_EDIT_FORM_TITLE", @"Balance.");
    
    // set font size of labels
    for(UILabel *label in self.labelsController) {
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:[YGTools defaultFontSize]], NSForegroundColorAttributeName:label.textColor,
                                     };
        NSAttributedString *attributed = [[NSAttributedString alloc] initWithString:label.text attributes:attributes];
        label.attributedText = attributed;
    }
    
    // disable date select
    self.labelDate.textColor = [UIColor grayColor];
    self.cellDate.accessoryType = UITableViewCellAccessoryNone;
    self.cellDate.textLabel.textColor = [UIColor grayColor]; // light?
    self.cellDate.userInteractionEnabled = NO;
    
    // changed?
    _isAccountChanged = NO;
    _isSumChanged = NO;
    _isCommentChanged = NO;
    
    //
    self.textFieldTargetSum.delegate = self;
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
    self.textFieldTargetSum.font = [UIFont systemFontOfSize:[YGTools defaultFontSize]];
    self.textViewComment.font = [UIFont systemFontOfSize:[YGTools defaultFontSize]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate & UITextViewDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if([textField isEqual:self.textFieldTargetSum])
        return [YGTools isValidSumWithZeroInSourceString:textField.text replacementString:string range:range];
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

#pragma mark - Property sum setter

- (void)setSum:(double)sum {
    _sum = round(sum * 100.0)/100.0;
}

#pragma mark - Come back from account choice controller

- (IBAction)unwindFromAccountChoiceToAccountActualEdit:(UIStoryboardSegue *)unwindSegue {
    
    YGAccountChoiceController *vc = unwindSegue.sourceViewController;
    
    _account = vc.targetAccount;
    //self.labelAccount.text = _account.name;
    self.labelAccount.attributedText = [YGTools attributedStringWithText:_account.name color:[UIColor blackColor]];
    
    _currency = [_cm categoryById:_account.currencyId type:YGCategoryTypeCurrency];

    self.labelTargetCurrency.attributedText = [YGTools attributedStringWithText:[_currency shorterName] color:[UIColor blackColor]];
    
    if([_account isEqual:_initAccountValue])
        _isAccountChanged = NO;
    else
        _isAccountChanged = YES;
    
    [self changeSaveButtonEnable];
}

#pragma mark - Monitoring of controls changed

- (IBAction)textFieldTargetSumEditingChanged:(UITextField *)sender {
    
    self.sum = [YGTools doubleFromStringCurrency:self.textFieldTargetSum.text];
    
    if(_initSumValue == self.sum)
        _isSumChanged = NO;
    else
        _isSumChanged = YES;
    
    if(self.sum < 0.00f || [self.textFieldTargetSum.text length] == 0)
        self.labelActualTitle.attributedText = [YGTools attributedStringWithText:[NSString stringWithFormat:@"%@", NSLocalizedString(@"SUM", @"Sum.")] color:[YGTools colorRed]];
    else
        self.labelActualTitle.attributedText = [YGTools attributedStringWithText:[NSString stringWithFormat:@"%@", NSLocalizedString(@"SUM", @"Sum.")] color:[UIColor blackColor]];
    
    [self changeSaveButtonEnable];
}

#pragma mark - UITextViewDelegate

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


- (BOOL)isEditControlsChanged {
    if(_isAccountChanged)
        return YES;
    if(_isSumChanged)
        return YES;
    if(_isCommentChanged)
        return YES;
    
    return NO;
}

- (BOOL)isDataReadyForSave {
    if(!_account)
        return NO;
    if(_sum < 0.0f)
        return NO;
    
    return YES;
}

#pragma mark - Change save button enable

- (void) changeSaveButtonEnable {
    if([self isEditControlsChanged] && [self isDataReadyForSave]) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        if(self.isNewAccountAcutal) {
            self.buttonSaveAndAddNew.enabled = YES;
            self.buttonSaveAndAddNew.titleLabel.textColor = [UIColor whiteColor];
            self.buttonSaveAndAddNew.backgroundColor = [YGTools colorForActionSaveAndAddNew];
        }
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        if(self.isNewAccountAcutal) {
            self.buttonSaveAndAddNew.enabled = NO;
            self.buttonSaveAndAddNew.titleLabel.textColor = [UIColor whiteColor];
            self.buttonSaveAndAddNew.backgroundColor = [YGTools colorForActionDisable];
        }
    }
}

#pragma mark - Save and delete actions

- (void)saveButtonPressed {
    [self saveAccountActual];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)buttonSaveAndAddNewPressed:(UIButton *)sender {
    [self saveAccountActual];
    [self initUIForNewAccountActual];
}

- (void)initUIForNewAccountActual {
    
    // init
    _initAccountValue = nil;
    _initCommentValue = nil;
    _initSumValue = 0.0f;

    _account = nil;
    _sum = 0.0f;
    _comment = nil;
    
    _isAccountChanged = NO;
    _isSumChanged = NO;
    _isCommentChanged = NO;
        
    // deactivate "Add" and "Save & add new" bottons
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.buttonSaveAndAddNew.enabled = NO;
    self.buttonSaveAndAddNew.backgroundColor = [YGTools colorForActionDisable];
    
    self.labelAccount.attributedText = [YGTools attributedStringWithText:NSLocalizedString(@"SELECT_ACCOUNT_LABEL", @"Select account.") color:[YGTools colorRed]];
    self.labelAccount.textColor = [YGTools colorRed];
    
    // set focus on sum only for new element
    self.textFieldTargetSum.text = nil;
    [self.textFieldTargetSum becomeFirstResponder];
    
    //
    self.labelActualTitle.textColor = [YGTools colorRed];
    self.labelTargetCurrency.text = @"?";
    self.labelTargetCurrency.textColor = [YGTools colorRed];
}

/**
 @warning Do i need any recalc?
 */
- (void)saveAccountActual {
    
    NSDate *now = [NSDate date];
    double sourceSum = _account.sum;
    double targetSum = [YGTools doubleFromStringCurrency:self.textFieldTargetSum.text];
    NSString *comment = [YGTools stringNilIfEmpty:[_comment stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    
    YGOperation *accountActual = [[YGOperation alloc]
                                  initWithType:YGOperationTypeAccountActual
                                  sourceId:_account.rowId
                                  targetId:_account.rowId
                                  sourceSum:sourceSum
                                  sourceCurrencyId:_account.currencyId
                                  targetSum:targetSum
                                  targetCurrencyId:_account.currencyId
                                  day:[p_day copy]
                                  created:[now copy]
                                  modified:[now copy]
                                  comment:comment];
    
    [_om addOperation:accountActual];
}

- (IBAction)buttonDeletePressed:(UIButton *)sender {
    [_om removeOperation:self.accountActual];
    [_em recalcSumOfAccount:_account forOperation:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"segueFromAccountActualEditToAccountChoice"]) {
        YGAccountChoiceController *vc = segue.destinationViewController;
        vc.sourceAccount = _account;
        vc.customer = YGAccountChoiceCustomerAccountActual;
    }
}

#pragma mark - Data source methods to show/hide action cells

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    
    if (indexPath.section == 3 && indexPath.row == 1 && !self.isNewAccountAcutal)
        height = 0;
    else if (indexPath.section == 3 && indexPath.row == 0 && self.isNewAccountAcutal)
        height = 0;
    
    return height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = [super tableView:tableView numberOfRowsInSection:section];
    if (section == 3)
        count = 2;
    
    return count;
}

@end
