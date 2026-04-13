//
//  YGTransferEditController.m
//  Ledger
//
//  Created by Ян on 23/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGTransferEditController.h"
#import "YGDateChoiceController.h"
#import "YGAccountChoiceController.h"
#import "YGEntityManager.h"
#import "YGCategoryManager.h"
#import "YGOperationManager.h"
#import "YGTools.h"
#import "YYGLedgerDefine.h"

@interface YGTransferEditController () <UITextFieldDelegate, UITextViewDelegate> {
    NSDate *p_day;
    YGEntity *_sourceAccount;
    YGCategory *_sourceCurrency;
    YGEntity *_targetAccount;
    YGCategory *_targetCurrency;
    NSString *_comment;
    
    BOOL _isDateChanged;
    BOOL _isSourceAccountChanged;
    BOOL _isSourceSumChanged;
    BOOL _isTargetAccountChanged;
    BOOL _isTargetSumChanged;
    BOOL _isCommentChanged;
    
    NSDate *_initDateValue;
    YGEntity *_initSourceAccountValue;
    double _initSourceSumValue;
    YGCategory *_initSourceCurrencyValue;
    double _initTargetSumValue;
    YGEntity *_initTargetAccountValue;
    YGCategory *_initTargetCurrencyValue;
    NSString *_initCommentValue;
    
    YGEntityManager *_em;
    YGCategoryManager *_cm;
    YGOperationManager *_om;
}

@property (assign, nonatomic) double sourceSum;
@property (assign, nonatomic) double targetSum;

@property (weak, nonatomic) IBOutlet UILabel *labelDate;
@property (weak, nonatomic) IBOutlet UILabel *labelSourceAccount;
@property (weak, nonatomic) IBOutlet UILabel *labelSourceSum;
@property (weak, nonatomic) IBOutlet UILabel *labelSourceCurrency;
@property (weak, nonatomic) IBOutlet UITextField *textFieldSourceSum;

@property (weak, nonatomic) IBOutlet UILabel *labelTargetAccount;
@property (weak, nonatomic) IBOutlet UILabel *labelTargetSum;
@property (weak, nonatomic) IBOutlet UILabel *labelTargetCurrency;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labelsController;

@property (weak, nonatomic) IBOutlet UITextField *textFieldTargetSum;
@property (weak, nonatomic) IBOutlet UITextView *textViewComment;

@property (weak, nonatomic) IBOutlet UITableViewCell *cellDelete;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellSaveAndAddNew;

@property (weak, nonatomic) IBOutlet UIButton *buttonDelete;
@property (weak, nonatomic) IBOutlet UIButton *buttonSaveAndAddNew;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttonsOfController;

- (IBAction)textFieldSourceSumEditingChanged:(UITextField *)sender;
- (IBAction)textFieldTargetSumEditingChanged:(UITextField *)sender;
- (IBAction)buttonDeletePressed:(UIButton *)sender;
- (IBAction)buttonSaveAndAddNewPressed:(UIButton *)sender;
@end

@implementation YGTransferEditController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _em = [YGEntityManager sharedInstance];
    _cm = [YGCategoryManager sharedInstance];
    _om = [YGOperationManager sharedInstance];
    
    if(self.isNewTransfer) {
        
        // set date
        p_day = [YGTools dayOfDate:[NSDate date]];
        self.labelDate.text = [YGTools humanViewWithTodayOfDate:p_day];

        // try to get last transfer
        YGOperation *lastOperation = [_om lastOperationForType:YGOperationTypeTransfer];
        
        if(lastOperation) {
            
            // set source account
            _sourceAccount = [_em entityById:lastOperation.sourceId type:YGEntityTypeAccount];
            self.labelSourceAccount.text = _sourceAccount.name;
            
            // set source currence
            //_sourceCurrency = [_cm categoryById:lastOperation.sourceCurrencyId];
            _sourceCurrency = [_cm categoryById:lastOperation.sourceCurrencyId type:YGCategoryTypeCurrency];
            self.labelSourceCurrency.text = [_sourceCurrency shorterName];
            
            // set target account
            _targetAccount = [_em entityById:lastOperation.targetId type:YGEntityTypeAccount];
            self.labelTargetAccount.text = _targetAccount.name;
            
            // set target currency
            _targetCurrency = [_cm categoryById:lastOperation.targetCurrencyId type:YGCategoryTypeCurrency];
            self.labelTargetCurrency.text = [_targetCurrency shorterName];
            
            self.buttonDelete.enabled = NO;
        } else {
            _sourceAccount = nil;
            self.labelSourceAccount.text = NSLocalizedString(@"SELECT_ACCOUNT_LABEL",  @"Select account");
            self.labelSourceAccount.textColor = [YGTools colorRed];
            self.sourceSum = 0.0;
            
            _targetAccount = nil;
            self.labelTargetAccount.text = NSLocalizedString(@"SELECT_ACCOUNT_LABEL",  @"Select account");
            self.labelTargetAccount.textColor = [YGTools colorRed];
            self.targetSum = 0.0;
        }
        
        self.labelSourceSum.attributedText = [YGTools attributedStringWithText:NSLocalizedString(@"SUM", @"Sum.") color:[YGTools colorRed]];
        self.labelTargetSum.attributedText = [YGTools attributedStringWithText:NSLocalizedString(@"SUM", @"Sum.") color:[YGTools colorRed]];
        
        // имитируем placeholder у textView
        self.textViewComment.text = NSLocalizedString(@"TEXT_VIEW_COMMENT_PLACEHOLDER", @"Placeholder for all textView for comments.");
        self.textViewComment.textColor = [UIColor lightGrayColor];
        self.textViewComment.delegate = self;
        
        // init
        _initDateValue = [p_day copy];
        _initSourceAccountValue = nil;
        _initSourceSumValue = 0.0f;
        _initSourceCurrencyValue = nil;
        _initTargetAccountValue = nil;
        _initTargetSumValue = 0.0f;
        _initSourceCurrencyValue = nil;
        _initCommentValue = nil;
        
        // hide button delete
        self.buttonDelete.enabled = NO;
        self.cellDelete.hidden = YES;
        //self.tableView.sec
        
        // show button save and add new
        self.cellSaveAndAddNew.hidden = NO;
        self.buttonSaveAndAddNew.enabled = NO;
        self.buttonSaveAndAddNew.titleLabel.textColor = [UIColor whiteColor];
        self.buttonSaveAndAddNew.backgroundColor = [YGTools colorForActionDisable];
        
        // set focus on sum only for new element
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kKeyboardAppearanceDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.textFieldSourceSum becomeFirstResponder];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        });
    } else {
        
        // set date
        p_day = self.transfer.day;
        self.labelDate.text = [YGTools humanViewWithTodayOfDate:p_day];
        
        // set source account
        _sourceAccount = [_em entityById:self.transfer.sourceId type:YGEntityTypeAccount];
        self.labelSourceAccount.text = _sourceAccount.name;
        
        // set source sum
        _sourceSum = self.transfer.sourceSum;
        //self.textFieldSourceSum.text = [NSString stringWithFormat:@"%.2f", _sourceSum];
        self.textFieldSourceSum.text = [YGTools stringCurrencyFromDouble:self.transfer.sourceSum];
        
        // set source currency
        //_sourceCurrency = [_cm categoryById:self.transfer.sourceCurrencyId];
        _sourceCurrency = [_cm categoryById:self.transfer.sourceCurrencyId type:YGCategoryTypeCurrency];
        self.labelSourceCurrency.text = [_sourceCurrency shorterName];
        
        // set target account
        _targetAccount = [_em entityById:self.transfer.targetId type:YGEntityTypeAccount];
        self.labelTargetAccount.text = _targetAccount.name;
        
        // set target sum
        _targetSum = self.transfer.targetSum;
        //self.textFieldTargetSum.text = [NSString stringWithFormat:@"%.2f", _targetSum];
        self.textFieldTargetSum.text = [YGTools stringCurrencyFromDouble:self.transfer.targetSum];
        
        // set target currency
        //_targetCurrency = [_cm categoryById:self.transfer.targetCurrencyId];
        _targetCurrency = [_cm categoryById:self.transfer.targetCurrencyId type:YGCategoryTypeCurrency];
        self.labelTargetCurrency.text = [_targetCurrency shorterName];
        
        // set comment
        _comment = self.transfer.comment;

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
        _initSourceAccountValue = [_sourceAccount copy];
        _initSourceSumValue = _sourceSum;
        _initSourceCurrencyValue = [_sourceCurrency copy];
        _initTargetAccountValue = [_targetAccount copy];
        _initTargetSumValue = _targetSum;
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
    self.navigationItem.title = NSLocalizedString(@"TRANSFER_EDIT_FORM_TITLE", @"Title of transfor edit form.");
    
    // init state for monitor user changes
    _isDateChanged = NO;
    _isSourceAccountChanged = NO;
    _isSourceSumChanged = NO;
    _isTargetAccountChanged = NO;
    _isTargetSumChanged = NO;
    _isCommentChanged = NO;
    
    self.textFieldSourceSum.delegate = self;
    self.textFieldTargetSum.delegate = self;
    self.textViewComment.delegate = self;
    
    [self setDefaultFontForControls];
}

- (void)setDefaultFontForControls {
    
    // set font size of labels
    for(UILabel *label in self.labelsController){
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:[YGTools defaultFontSize]], NSForegroundColorAttributeName:label.textColor,
                                     };
        NSAttributedString *attributed = [[NSAttributedString alloc] initWithString:label.text attributes:attributes];
        label.attributedText = attributed;
    }
    
    for(UIButton *button in self.buttonsOfController) {
        button.titleLabel.font = [UIFont boldSystemFontOfSize:[YGTools defaultFontSize]];
    }
    
    // set font size of textField and textView
    self.textFieldSourceSum.font = [UIFont systemFontOfSize:[YGTools defaultFontSize]];
    self.textFieldTargetSum.font = [UIFont systemFontOfSize:[YGTools defaultFontSize]];
    self.textViewComment.font = [UIFont systemFontOfSize:[YGTools defaultFontSize]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate & UITextViewDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if([textField isEqual:self.textFieldTargetSum]
       || [textField isEqual:self.textFieldSourceSum])
        return [YGTools isValidSumInSourceString:textField.text replacementString:string range:range];
    else
        return NO;
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([textView isEqual:self.textViewComment])
        return [YGTools isValidCommentInSourceString:textView.text replacementString:text range:range];
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

#pragma mark - Properties source and target sums setters

- (void)setSourceSum:(double)sourceSum {
    _sourceSum = round(sourceSum * 100.0)/100.0;
    
}

- (void)setTargetSum:(double)targetSum {
    _targetSum = round(targetSum * 100.0)/100.0;
}

#pragma mark - Come back from other choice controllers

- (IBAction)unwindFromDateChoiceToTransferEdit:(UIStoryboardSegue *)unwindSegue {
    
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

- (IBAction)unwindFromSourceAccountChoiceToTransferEdit:(UIStoryboardSegue *)unwindSegue {
    
    YGAccountChoiceController *vc = unwindSegue.sourceViewController;
    
    _sourceAccount = vc.targetAccount;
    self.labelSourceAccount.attributedText = [YGTools attributedStringWithText:_sourceAccount.name color:[UIColor blackColor]];
    
    // may be lazy?
    //_sourceCurrency = [_cm categoryById:_sourceAccount.currencyId];
    _sourceCurrency = [_cm categoryById:_sourceAccount.currencyId type:YGCategoryTypeCurrency];
    //self.labelSourceCurrency.text = [_sourceCurrency shorterName];
    self.labelSourceCurrency.attributedText = [YGTools attributedStringWithText:[_sourceCurrency shorterName] color:[UIColor blackColor]];
    
    if([_sourceAccount isEqual:_initSourceAccountValue])
        _isSourceAccountChanged = NO;
    else
        _isSourceAccountChanged = YES;
    
    // if choosen sourceAccount == targetAccount unselect target
    if([_sourceAccount isEqual:_targetAccount]) {
        _targetAccount = nil;
        self.labelTargetAccount.attributedText = [YGTools attributedStringWithText:NSLocalizedString(@"SELECT_ACCOUNT_LABEL", @"Select account") color:[YGTools colorRed]];
        self.labelTargetCurrency.text = @"";
    }
    
    [self.textFieldSourceSum becomeFirstResponder];
    
    [self changeSaveButtonEnable];
}

- (IBAction)unwindFromTargetAccountChoiceToTransferEdit:(UIStoryboardSegue *)unwindSegue {
    
    YGAccountChoiceController *vc = unwindSegue.sourceViewController;
    
    _targetAccount = vc.targetAccount;
    //self.labelTargetAccount.text = _targetAccount.name;
    self.labelTargetAccount.attributedText = [YGTools attributedStringWithText:_targetAccount.name color:[UIColor blackColor]];
    
    _targetCurrency = [_cm categoryById:_targetAccount.currencyId type:YGCategoryTypeCurrency];
    //self.labelTargetCurrency.text = [_targetCurrency shorterName];
    self.labelTargetCurrency.attributedText = [YGTools attributedStringWithText:[_targetCurrency shorterName] color:[UIColor blackColor]];
    
    if([_targetAccount isEqual:_initTargetAccountValue])
        _isTargetAccountChanged = NO;
    else
        _isTargetAccountChanged = YES;
    
    if(_sourceAccount.currencyId == _targetAccount.currencyId && _sourceSum > 0.0 && _targetSum == 0.0) {
        self.textFieldTargetSum.text = [self.textFieldSourceSum.text copy];
        //self.labelTargetSum.textColor = [UIColor blueColor];
        [self textFieldTargetSumEditingChanged:self.textFieldTargetSum];
    }
    
    [self.textFieldTargetSum becomeFirstResponder];
    
    [self changeSaveButtonEnable];
}

- (BOOL) isEditControlsChanged {
    if(_isDateChanged)
        return YES;
    if(_isSourceAccountChanged)
        return YES;
    if(_isSourceSumChanged)
        return YES;
    if(_isTargetAccountChanged)
        return YES;
    if(_isTargetSumChanged)
        return YES;
    if(_isCommentChanged)
        return YES;
    
    return NO;
}

- (BOOL) isDataReadyForSave {
    if(!p_day)
        return NO;
    if(!_sourceAccount)
        return NO;
    if(_sourceSum <= 0)
        return NO;
    if(!_targetAccount)
        return NO;
    if(_targetSum <= 0)
        return NO;
    if([_sourceAccount isEqual:_targetAccount])
        return NO;
    
    return YES;
}

#pragma mark - Change save button enable

- (void) changeSaveButtonEnable {
    
    if([self isEditControlsChanged] && [self isDataReadyForSave]) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        if(self.isNewTransfer) {
            self.buttonSaveAndAddNew.enabled = YES;
            self.buttonSaveAndAddNew.titleLabel.textColor = [UIColor whiteColor];
            self.buttonSaveAndAddNew.backgroundColor = [YGTools colorForActionSaveAndAddNew];
        }
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        if(self.isNewTransfer) {
            self.buttonSaveAndAddNew.enabled = NO;
            self.buttonSaveAndAddNew.titleLabel.textColor = [UIColor whiteColor];
            self.buttonSaveAndAddNew.backgroundColor = [YGTools colorForActionDisable];
        }
    }
}

#pragma mark - Monitoring of controls changed

- (IBAction)textFieldSourceSumEditingChanged:(UITextField *)sender {
    
    //self.sourceSum =  [self.textFieldSourceSum.text doubleValue];
    self.sourceSum = [YGTools doubleFromStringCurrency:self.textFieldSourceSum.text];
    
    if(_initSourceSumValue == self.sourceSum)
        _isSourceSumChanged = NO;
    else
        _isSourceSumChanged = YES;
    
    if(self.sourceSum == 0.00f)
        self.labelSourceSum.attributedText = [YGTools attributedStringWithText:[NSString stringWithFormat:@"%@", NSLocalizedString(@"SUM", @"Sum")] color:[YGTools colorRed]];
    else
        self.labelSourceSum.attributedText = [YGTools attributedStringWithText:[NSString stringWithFormat:@"%@", NSLocalizedString(@"SUM", @"Sum")] color:[UIColor blackColor]];
    
    [self changeSaveButtonEnable];
}

- (IBAction)textFieldTargetSumEditingChanged:(UITextField *)sender {
    
    //self.targetSum =  [self.textFieldTargetSum.text doubleValue];
    self.targetSum = [YGTools doubleFromStringCurrency:self.textFieldTargetSum.text];
    
    if(_initTargetSumValue == self.targetSum)
        _isTargetSumChanged = NO;
    else
        _isTargetSumChanged = YES;
    
    if(self.targetSum == 0.00f)
        self.labelTargetSum.attributedText = [YGTools attributedStringWithText:[NSString stringWithFormat:@"%@", NSLocalizedString(@"SUM", @"Sum")] color:[YGTools colorRed]];
    else
        self.labelTargetSum.attributedText = [YGTools attributedStringWithText:[NSString stringWithFormat:@"%@", NSLocalizedString(@"SUM", @"Sum")] color:[UIColor blackColor]];
    
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
    [self saveTransfer];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)buttonSaveAndAddNewPressed:(UIButton *)sender {
    [self saveTransfer];
    [self initUIForNewExpense];
}

- (void)initUIForNewExpense {
    
    // init
    _initDateValue = [p_day copy];
    
    _initSourceAccountValue = [_sourceAccount copy];
    _initSourceSumValue = 0.0f;
    _initTargetAccountValue = [_targetAccount copy];
    _initTargetSumValue = 0.0f;
    _initCommentValue = @"";
    
    // init state for monitor user changes
    _isDateChanged = NO;
    _isSourceAccountChanged = NO;
    _isSourceSumChanged = NO;
    _isTargetAccountChanged = NO;
    _isTargetSumChanged = NO;
    _isCommentChanged = NO;
    
    // deactivate "Add" and "Save & add new" bottons
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.buttonSaveAndAddNew.enabled = NO;
    self.buttonSaveAndAddNew.backgroundColor = [YGTools colorForActionDisable];
    
    // set focus on sum only for new element
    self.textFieldSourceSum.text = @"";
    self.textFieldTargetSum.text = @"";
    
    [self.textFieldSourceSum becomeFirstResponder];
}

- (void)saveTransfer {
    
    NSDate *now = [NSDate date];
    NSString *comment = [_comment stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if(self.isNewTransfer) {
        
        YGOperation *transfer = [[YGOperation alloc]
                                 initWithType:YGOperationTypeTransfer
                                 sourceId:_sourceAccount.rowId
                                 targetId:_targetAccount.rowId
                                 sourceSum:_sourceSum
                                 sourceCurrencyId:_sourceAccount.currencyId
                                 targetSum:_targetSum
                                 targetCurrencyId:_targetAccount.currencyId
                                 day:[p_day copy]
                                 created:[now copy]
                                 modified:[now copy]
                                 comment:comment];
        
        
        NSInteger operationId = [_om addOperation:transfer];
        transfer.rowId = operationId;
        
        [_em recalcSumOfAccount:_sourceAccount forOperation:transfer];
        [_em recalcSumOfAccount:_targetAccount forOperation:transfer];
    } else {
        
        YGOperation *oldTransfer = [self.transfer copy];
        
        if(_isDateChanged)
            self.transfer.day = [p_day copy];
        if(_isSourceAccountChanged){
            self.transfer.sourceId = _sourceAccount.rowId;
            self.transfer.sourceCurrencyId = _sourceCurrency.rowId;
        }
        if(_isTargetAccountChanged) {
            self.transfer.targetId = _targetAccount.rowId;
            self.transfer.targetCurrencyId = _targetCurrency.rowId;
        }
        if(_isSourceSumChanged)
            self.transfer.sourceSum = _sourceSum;
        if(_isTargetSumChanged)
            self.transfer.targetSum = _targetSum;
        if(_isCommentChanged)
            self.transfer.comment = comment;
        
        self.transfer.modified = now;
        
        [_om updateOperation:oldTransfer withNew:[self.transfer copy]];
        
        // need to recalc?
        if(_isDateChanged || _isSourceAccountChanged || _isSourceSumChanged || _isTargetAccountChanged || _isTargetSumChanged) {
            
            [_em recalcSumOfAccount:_sourceAccount forOperation:nil];
            [_em recalcSumOfAccount:_targetAccount forOperation:nil];
            
            // recalc of old account
            if(_isSourceAccountChanged)
                [_em recalcSumOfAccount:[_initSourceAccountValue copy] forOperation:nil];
            
            // recalc of old account
            if(_isTargetAccountChanged)
                [_em recalcSumOfAccount:[_initTargetAccountValue copy] forOperation:nil];
        }
    }
}

- (IBAction)buttonDeletePressed:(UIButton *)sender {
    [_om removeOperation:self.transfer];
    [_em recalcSumOfAccount:_sourceAccount forOperation:nil];
    [_em recalcSumOfAccount:_targetAccount forOperation:nil];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if([segue.identifier isEqualToString:@"segueFromTransferEditToDateChoice"]) {
        
        YGDateChoiceController *vc = segue.destinationViewController;
        
        vc.sourceDate = p_day;
        vc.customer = YGDateChoiceСustomerTransfer;
        
    }
    else if([segue.identifier isEqualToString:@"segueFromTransferEditToSourceAccountChoice"]) {
        
        YGAccountChoiceController *vc = segue.destinationViewController;
        
        vc.sourceAccount = _sourceAccount;
        vc.customer = YGAccountChoiceCustomerTransferSource;
        
    }
    else if([segue.identifier isEqualToString:@"segueFromTransferEditToTargetAccountChoice"]) {
        
        YGAccountChoiceController *vc = segue.destinationViewController;
        
        //vc.sourceAccount = _targetAccount;
        vc.sourceAccount = _sourceAccount;
        vc.customer = YGAccountChoiceCustomerTransferTarget;
    }
}

#pragma mark - Data source methods to show/hide action cells

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    
    if (indexPath.section == 3 && indexPath.row == 1 && !self.isNewTransfer) {
        height = 0;
    }
    else if (indexPath.section == 3 && indexPath.row == 0 && self.isNewTransfer) {
        height = 0;
    }
    
    return height;
}

@end
