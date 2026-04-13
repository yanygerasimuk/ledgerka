//
//  YGCurrencyEditController.m
//  Ledger
//
//  Created by Ян on 01/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGCurrencyEditController.h"
#import "YGCategoryManager.h"
#import "YGTools.h"
#import "YYGLedgerDefine.h"

@interface YGCurrencyEditController () <UITextFieldDelegate, UITextViewDelegate> {
    
    NSString *p_name;
    NSString *p_symbol;
    NSInteger p_sort;
    NSString *p_comment;
    BOOL p_isDefault;
    
    BOOL _isNameChanged;
    BOOL _isSymbolChanged;
    BOOL _isSortChanged;
    BOOL _isCommentChanged;
    BOOL _isDefaultChanged;
    
    NSString *_initNameValue;
    NSString *_initSymbolValue;
    NSInteger _initSortValue;
    BOOL _initDefaultValue;
    NSString *_initCommentValue;
    
    YGCategoryManager *p_manager;
}

@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelSymbol;
@property (weak, nonatomic) IBOutlet UILabel *labelSort;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labelsOfController;

@property (weak, nonatomic) IBOutlet UITextField *currencyName;
@property (weak, nonatomic) IBOutlet UITextField *currencySymbol;
@property (weak, nonatomic) IBOutlet UITextField *currencySort;
@property (weak, nonatomic) IBOutlet UITextView *textViewComment;

@property (weak, nonatomic) IBOutlet UIButton *buttonActivate;
@property (weak, nonatomic) IBOutlet UIButton *buttonDelete;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttonsOfController;

@property (weak, nonatomic) IBOutlet UISwitch *currencyIsDefault;

- (IBAction)textNameChanged:(id)sender;
- (IBAction)textSymbolChanged:(id)sender;
- (IBAction)textSortChanged:(id)sender;
- (IBAction)sliderDefaultChanged:(id)sender;
- (IBAction)buttonActivatePressed:(UIButton *)sender;
- (IBAction)buttonDeletePressed:(UIButton *)sender;

@end

@implementation YGCurrencyEditController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    p_manager = [YGCategoryManager sharedInstance];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed)];
    
    self.navigationItem.rightBarButtonItem = saveButton;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    self.navigationItem.title = [self.viewModel title];
    
    if(self.viewModel.isNew){
        self.viewModel.category = nil;
        p_name = nil;
        
        self.currencySort.text = @"100";
        p_sort = 100;
        
        self.currencyIsDefault.on = NO;
        p_isDefault = NO;
        
        p_comment = nil;
        // имитируем placeholder у textView
        self.textViewComment.text = NSLocalizedString(@"TEXT_VIEW_COMMENT_PLACEHOLDER", @"Placeholder for all textView for comments.");
        self.textViewComment.textColor = [UIColor lightGrayColor];
        self.textViewComment.delegate = self;
        
        self.buttonActivate.enabled = NO;
        self.buttonActivate.titleLabel.text = NSLocalizedString(@"DEACTIVATE_BUTTON_TITLE", @"Title of Deactivate button.");

        self.buttonDelete.enabled = NO;
        
        self.labelName.textColor = [YGTools colorRed];
        self.labelSymbol.textColor = [YGTools colorRed];
        
        // focus
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kKeyboardAppearanceDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.currencyName becomeFirstResponder];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        });
    } else {
        self.currencyName.text = self.viewModel.category.name;
        p_name = self.viewModel.category.name;
        
        self.currencySymbol.text = self.viewModel.category.symbol;
        p_symbol = self.viewModel.category.symbol;
        
        self.currencySort.text = [NSString stringWithFormat:@"%ld", (long)self.viewModel.category.sort];
        p_sort = self.viewModel.category.sort;
        
        self.currencyIsDefault.on = self.viewModel.category.isAttach;
        p_isDefault = self.viewModel.category.isAttach;
        
        p_comment = self.viewModel.category.comment;
        
        // если комментария нет, то имитируем placeholder
        if(p_comment && ![p_comment isEqualToString:@""]){
            self.textViewComment.text = p_comment;
            self.textViewComment.textColor = [UIColor blackColor];
        }
        else{
            self.textViewComment.text = NSLocalizedString(@"TEXT_VIEW_COMMENT_PLACEHOLDER", @"Placeholder for all textView for comments.");
            self.textViewComment.textColor = [UIColor lightGrayColor];
        }
        self.textViewComment.delegate = self;
        
        self.buttonActivate.enabled = YES;
        self.buttonDelete.enabled = YES;
        
        if(self.viewModel.category.active){
            [self.buttonActivate setTitle:NSLocalizedString(@"DEACTIVATE_BUTTON_TITLE", @"Title of Deactivate button.") forState:UIControlStateNormal];
            self.buttonActivate.backgroundColor = [YGTools colorForActionDeactivate];
        } else {
            [self.buttonActivate setTitle:NSLocalizedString(@"ACTIVATE_BUTTON_TITLE", @"Title of Activate button.") forState:UIControlStateNormal];
            self.buttonActivate.backgroundColor = [YGTools colorForActionActivate];
        }
    }
    
    _isNameChanged = NO;
    _isSymbolChanged = NO;
    _isSortChanged = NO;
    _isDefaultChanged = NO;
    _isCommentChanged = NO;
    
    _initNameValue = [p_name copy];
    _initSymbolValue = [p_symbol copy];
    _initSortValue = p_sort;
    _initDefaultValue = p_isDefault;
    _initCommentValue = [p_comment copy];
    
    [self.buttonActivate setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    [self.buttonActivate setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.buttonDelete setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    [self.buttonDelete setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    self.currencyName.delegate = self;
    self.currencySymbol.delegate = self;
    self.currencySort.delegate = self;
    self.textViewComment.delegate = self;
    
    [self setDefaultFontForControls];
}

- (void)setDefaultFontForControls {
    
    // set font size of labels
    for(UILabel *label in self.labelsOfController){
        
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:[YGTools defaultFontSize]], NSForegroundColorAttributeName:label.textColor,
                                     };
        NSAttributedString *attributed = [[NSAttributedString alloc] initWithString:label.text attributes:attributes];
        label.attributedText = attributed;
    }
    
    for(UIButton *button in self.buttonsOfController){
        button.titleLabel.font = [UIFont boldSystemFontOfSize:[YGTools defaultFontSize]];
    }
    
    // set font size of textField and textView
    self.currencyName.font = [UIFont systemFontOfSize:[YGTools defaultFontSize]];
    self.currencySort.font = [UIFont systemFontOfSize:[YGTools defaultFontSize]];
    self.currencySymbol.font = [UIFont systemFontOfSize:[YGTools defaultFontSize]];
    self.textViewComment.font = [UIFont systemFontOfSize:[YGTools defaultFontSize]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate & UITextViewDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if([textField isEqual:self.currencyName])
        return [YGTools isValidNameInSourceString:textField.text replacementString:string range:range];
    else if([textField isEqual:self.currencySymbol])
        return [YGTools isValidSymbolInSourceString:textField.text replacementString:string range:range];
    else if([textField isEqual:self.currencySort])
        return [YGTools isValidSortInSourceString:textField.text replacementString:string range:range];
    else
        return NO;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([textView isEqual:self.textViewComment]) {
        
        return [YGTools isValidCommentInSourceString:textView.text replacementString:text range:range];
    } else
        return NO;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    if([textView isEqual:self.textViewComment]){
        
        if(textView.text && [textView.text isEqualToString:NSLocalizedString(@"TEXT_VIEW_COMMENT_PLACEHOLDER", @"Placeholder for all textView for comments.")]){
            textView.text = @"";
            textView.textColor = [UIColor blackColor];
        }
    }
    
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    if([textView isEqual:self.textViewComment]){
        
        if(!textView.text || [textView.text isEqualToString:@""]){
            textView.text = NSLocalizedString(@"TEXT_VIEW_COMMENT_PLACEHOLDER", @"Placeholder for all textView for comments.");
            textView.textColor = [UIColor lightGrayColor];
        }
    }
    
    [textView resignFirstResponder];
}

#pragma mark - Monitoring of control value changed

- (IBAction)textNameChanged:(id)sender{
    
    if(self.currencyName.text)
        p_name = [self.currencyName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    else
        p_name = nil;
    
    if(p_name && [p_name isEqualToString:@""])
        p_name = nil;
    
    if([_initNameValue isEqualToString:p_name])
        _isNameChanged = NO;
    else
        _isNameChanged = YES;
    
    if(!p_name)
        self.labelName.textColor = [YGTools colorRed];
    else
        self.labelName.textColor = [UIColor blackColor];
    
    [self changeSaveButtonEnable];
}

- (IBAction)textSymbolChanged:(id)sender{
    
    p_symbol = self.currencySymbol.text;
    
    if([_initSymbolValue isEqualToString:p_symbol])
        _isSymbolChanged = NO;
    else
        _isSymbolChanged = YES;
    
    if([self.currencySymbol.text isEqualToString:@""])
        self.labelSymbol.textColor = [YGTools colorRed];
    else
        self.labelSymbol.textColor = [UIColor blackColor];
    
    [self changeSaveButtonEnable];
}

- (IBAction)textSortChanged:(id)sender{
    
    p_sort = [self.currencySort.text integerValue];
    
    if(_initSortValue == p_sort)
        _isSortChanged = NO;
    else
        _isSortChanged = YES;
    
    if([self.currencySort.text isEqualToString:@""])
        self.labelSort.textColor = [YGTools colorRed];
    else
        self.labelSort.textColor = [UIColor blackColor];
    
    [self changeSaveButtonEnable];
}

- (IBAction)sliderDefaultChanged:(id)sender {
    
    p_isDefault = self.currencyIsDefault.isOn;
    
    if(_initDefaultValue == p_isDefault)
        _isDefaultChanged = NO;
    else
        _isDefaultChanged = YES;
    
    [self changeSaveButtonEnable];
}

- (void)textViewDidChange:(UITextView *)textView {
    
    if([textView isEqual:self.textViewComment]){
        
        if(textView.text)
            p_comment = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        else
            p_comment = nil;
        
        if(p_name && [p_name isEqualToString:@""])
            p_comment = nil;
        
        if([_initCommentValue isEqualToString:p_comment])
            _isCommentChanged = NO;
        else
            _isCommentChanged = YES;
        
        [self changeSaveButtonEnable];
    }
}

- (BOOL)isEditControlsChanged {
    
    if(_isNameChanged)
        return YES;
    if(_isSymbolChanged)
        return YES;
    if(_isSortChanged)
        return YES;
    if(_isCommentChanged)
        return YES;
    if(_isDefaultChanged)
        return YES;
    
    return NO;
}

- (BOOL) isDataReadyForSave {
    if(!p_name || [p_name isEqualToString:@""])
        return NO;
    if(!p_symbol || [p_symbol isEqualToString:@""])
        return NO;
    if(p_sort < 1 || p_sort > 999)
        return NO;
    
    return YES;
}

#pragma mark - Change save button enable

- (void) changeSaveButtonEnable{
    
    if([self isEditControlsChanged] && [self isDataReadyForSave])
        self.navigationItem.rightBarButtonItem.enabled = YES;
    else
        self.navigationItem.rightBarButtonItem.enabled = NO;
}

#pragma mark - Save, activate/deactivate and delete actions

- (void)saveButtonPressed {
    
    p_name = [p_name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    p_comment = [p_comment stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if(self.viewModel.isNew) {
        YGCategory *currency = [[YGCategory alloc]
                                initWithType:YGCategoryTypeCurrency
                                name:p_name
                                sort:p_sort
                                symbol:p_symbol
                                attach:p_isDefault
                                parentId:-1
                                comment:p_comment];
        
        [p_manager addCategory:[currency copy]];
    } else {
        if(_isNameChanged)
            _viewModel.category.name = p_name;
        if(_isSymbolChanged)
            _viewModel.category.symbol = p_symbol;
        if(_isSortChanged)
            _viewModel.category.sort = p_sort;
        if(_isDefaultChanged)
            _viewModel.category.attach = p_isDefault;
        if(_isCommentChanged)
            _viewModel.category.comment = p_comment;
        
        _viewModel.category.modified = [NSDate date];
        
        [p_manager updateCategory:[_viewModel.category copy]];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)buttonActivatePressed:(UIButton *)sender {
    
    if(_viewModel.category.active) {
        
        if(![p_manager hasActiveCategoryForTypeExceptCategory:_viewModel.category]) {
            
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"CAN_NOT_DEACTIVATE_ALERT_TITLE", @"Title of alert Can not deactivate") message:NSLocalizedString(@"CAN_NOT_DEACTIVATE_BECOUSE_APP_NEED_AT_LEAST_ONE_ACTIVE_CURRENCY", @"Message with reason that applicatin must have at least one active currency") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [controller addAction:actionOk];
            [self presentViewController:controller animated:YES completion:nil];
            
            [self disableButtonActivate];
            
            return;
        }
        
        [p_manager deactivateCategory:_viewModel.category];
    } else {
        [p_manager activateCategory:_viewModel.category];
    }
    
    // the best way is return to list of categories
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)buttonDeletePressed:(UIButton *)sender {
    
    if([p_manager hasLinkedObjectsForCategory:_viewModel.category]) {
        
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"CAN_NOT_DELETE_ALERT_TITLE", @"Title of alert Can not delete") message:NSLocalizedString(@"CAN_NOT_DELETE_BECOUSE_CATEGORY_HAS_LINKED_OBJECTS_MESSAGE", @"The currency has linked objects (operations, accounts, debts, etc.)") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [controller addAction:actionOk];
        [self presentViewController:controller animated:YES completion:nil];
        
        [self disableButtonDelete];
        
        return;
    }
    
    // check for removed category just one active
    if(![p_manager hasActiveCategoryForTypeExceptCategory:_viewModel.category]) {
        
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"CAN_NOT_DELETE_ALERT_TITLE", @"Title of alert Can not delete") message:NSLocalizedString(@"REASON_CAN_NOT_DELETE_BECOUSE_ABSENT_ANOTHER_ACTIVE_CATEGORY_FOR_TYPE_MESSAGE", @"Message with reason that category is only one active for type and another is not exists.") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [controller addAction:actionOk];
        [self presentViewController:controller animated:YES completion:nil];
        
        [self disableButtonDelete];
        
        return;
    }
    
    // check for removed category just one
    if([p_manager isJustOneCategory:_viewModel.category]) {
        
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"CAN_NOT_DELETE_ALERT_TITLE", @"Title of alert Can not delete") message:NSLocalizedString(@"REASON_CAN_NOT_DELETE_BECOUSE_ONLY_ONE_CATEGORY_EXISTS_FOR_TYPE_MESSAGE", @"Message with reason that category is only one for type and can not be deleted.") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [controller addAction:actionOk];
        [self presentViewController:controller animated:YES completion:nil];
        
        [self disableButtonDelete];
        
        return;
    }
    
    [p_manager removeCategory:_viewModel.category];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)disableButtonDelete {
    self.buttonDelete.enabled = NO;
    self.buttonDelete.backgroundColor = [UIColor lightGrayColor];
    self.buttonDelete.titleLabel.textColor = [UIColor whiteColor];
}

- (void)disableButtonActivate {
    self.buttonDelete.enabled = NO;
    self.buttonDelete.backgroundColor = [UIColor lightGrayColor];
    self.buttonDelete.titleLabel.textColor = [UIColor whiteColor];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    
    // action delete
    if(indexPath.section == 3 && indexPath.row == 1) {
        
        if(self.viewModel.category) {
            if([p_manager hasLinkedObjectsForCategory:_viewModel.category]
               || ![p_manager hasActiveCategoryForTypeExceptCategory:_viewModel.category]
               || [p_manager isJustOneCategory:_viewModel.category]){
                height = 0.0f;
            }
        } else {
            height = 0.0f;
        }
    }
    
    // action deactivate
    if(indexPath.section == 3 && indexPath.row == 0) {
        
        if(self.viewModel.category && self.viewModel.category.active) {
            
            if(![p_manager hasActiveCategoryForTypeExceptCategory:_viewModel.category]
               || [p_manager hasLinkedActiveEntityForCurrency:_viewModel.category])
                height = 0.0f;
        }
        else if(!self.viewModel.category) {
            height = 0.0f;
        }
    }
    
    return height;
}

#pragma mark - Tools

- (NSInteger)sortValueFromString:(NSString *)string {
    
    NSInteger result = 100;
    
    @try {
        if(string && [string length] > 0){
            result = [string integerValue];
        }
    } @catch (NSException *ex) {
        NSLog(@"Error in -[YGCurrencyEditController sortFromString]. Exception: %@", [ex description]);
    } @finally {
        return result;
    }
}

@end
