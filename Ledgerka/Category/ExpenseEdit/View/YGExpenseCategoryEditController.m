//
//  YGExpenseCategoryEditController.m
//  Ledger
//
//  Created by Ян on 14/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGExpenseCategoryEditController.h"
#import "YYGExpenseParentChoiceController.h"
#import "YGCategoryManager.h"
#import "YGTools.h"
#import "YYGLedgerDefine.h"

@interface YGExpenseCategoryEditController () <UITextFieldDelegate, UITextViewDelegate> {
    
    NSString *p_name;
    NSInteger p_sort;
    NSString *p_comment;
    
    BOOL _isNameChanged;
    BOOL _isSortChanged;
    BOOL _isCommentChanged;
    BOOL _isParentChanged;
    
    NSString *_initNameValue;
    NSInteger _initSortValue;
    NSString *_initCommentValue;
    YGCategory *_initParentValue;
    
    YGCategoryManager *p_manager;
}

@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelSort;
@property (weak, nonatomic) IBOutlet UILabel *labelParent;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labelsOfController;

@property (weak, nonatomic) IBOutlet UITextField *textFieldName;
@property (weak, nonatomic) IBOutlet UITextField *textFieldSort;
@property (weak, nonatomic) IBOutlet UITextView *textViewComment;

@property (weak, nonatomic) IBOutlet UIButton *buttonActivate;
@property (weak, nonatomic) IBOutlet UIButton *buttonDelete;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttonsOfController;

@property (weak, nonatomic) IBOutlet UITableViewCell *cellParentCategory;

- (IBAction)buttonActivatePressed:(UIButton *)sender;
- (IBAction)buttonDeletePressed:(UIButton *)sender;
- (IBAction)textFieldNameEditingChanged:(UITextField *)sender;
- (IBAction)textFieldSortEditingChanged:(UITextField *)sender;

@end

@implementation YGExpenseCategoryEditController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    p_manager = [YGCategoryManager sharedInstance];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed)];
    
    self.navigationItem.rightBarButtonItem = saveButton;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    self.navigationItem.title = NSLocalizedString(@"EXPENSE_CATEGORY_EDIT_FORM_TITLE", @"Title of Expense category view/edit form.");
    
    if(self.viewModel.isNew) {
        
        self.viewModel.category = nil;
        p_name = nil;
        self.labelName.textColor = [YGTools colorRed];
        
        self.textFieldSort.text = @"100";
        p_sort = 100;
        
        self.buttonActivate.enabled = NO;
        self.buttonActivate.titleLabel.text = NSLocalizedString(@"DEACTIVATE_BUTTON_TITLE", @"Title of Deactivate button.");
        
        self.buttonDelete.enabled = NO;
        
        self.labelParent.text = NSLocalizedString(@"ROOT_CATEGORY_LABEL", @"Name of Root category");
        _initParentValue = nil;
        
        // имитируем placeholder у textView
        self.textViewComment.text = NSLocalizedString(@"TEXT_VIEW_COMMENT_PLACEHOLDER", @"Placeholder for all textView for comments.");
        self.textViewComment.textColor = [UIColor lightGrayColor];
        self.textViewComment.delegate = self;
        
        // focus
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kKeyboardAppearanceDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.textFieldName becomeFirstResponder];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        });
    } else {
        
        self.textFieldName.text = self.viewModel.category.name;
        p_name = self.viewModel.category.name;
        
        self.textFieldSort.text = [NSString stringWithFormat:@"%ld",(long)self.viewModel.category.sort];
        p_sort = self.viewModel.category.sort;
        
        p_comment = self.viewModel.category.comment;
        
        // если комментария нет, то имитируем placeholder
        if(p_comment && ![p_comment isEqualToString:@""]) {
            self.textViewComment.text = p_comment;
            self.textViewComment.textColor = [UIColor blackColor];
        } else {
            self.textViewComment.text = NSLocalizedString(@"TEXT_VIEW_COMMENT_PLACEHOLDER", @"Placeholder for all textView for comments.");
            self.textViewComment.textColor = [UIColor lightGrayColor];
        }
        self.textViewComment.delegate = self;
        
        self.buttonActivate.enabled = YES;
        self.buttonDelete.enabled = YES;
        
        if(self.viewModel.category.active) {
            [self.buttonActivate setTitle:NSLocalizedString(@"DEACTIVATE_BUTTON_TITLE", @"Title of Deactivate button.") forState:UIControlStateNormal];
            self.buttonActivate.backgroundColor = [YGTools colorForActionDeactivate];
        } else {
            [self.buttonActivate setTitle:NSLocalizedString(@"ACTIVATE_BUTTON_TITLE", @"Title of Activate button.") forState:UIControlStateNormal];
            self.buttonActivate.backgroundColor = [YGTools colorForActionActivate];
        }
        
        if(_viewModel.category.parentId > 0) {
            
            _viewModel.parent = [p_manager categoryById:_viewModel.category.parentId type:YGCategoryTypeExpense];
            self.labelParent.text = _viewModel.parent.name;
            
            _initParentValue = [_viewModel.parent copy];
            
        } else {
            self.labelParent.text = NSLocalizedString(@"ROOT_CATEGORY_LABEL", @"Name of Root category");
            _viewModel.parent = nil;
            _initParentValue = nil;
        }
    }
    
    _isNameChanged = NO;
    _isSortChanged = NO;
    _isCommentChanged = NO;
    _isParentChanged = NO;
    
    _initNameValue = p_name;
    _initSortValue = p_sort;
    _initCommentValue = p_comment;
    
    [self.buttonActivate setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.buttonActivate setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    
    self.textFieldName.delegate = self;
    self.textFieldSort.delegate = self;
    self.textViewComment.delegate = self;
    
    [self updateUI];
    
    [self setDefaultFontForControls];
}

- (void)setDefaultFontForControls {
    
    // set font size of labels
    for(UILabel *label in self.labelsOfController) {
        
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:[YGTools defaultFontSize]], NSForegroundColorAttributeName:label.textColor,
                                     };
        NSAttributedString *attributed = [[NSAttributedString alloc] initWithString:label.text attributes:attributes];
        label.attributedText = attributed;
    }
    
    for(UIButton *button in self.buttonsOfController) {
        button.titleLabel.font = [UIFont boldSystemFontOfSize:[YGTools defaultFontSize]];
    }
        
    // set font size of textField and textView
    self.textFieldName.font = [UIFont systemFontOfSize:[YGTools defaultFontSize]];
    self.textFieldSort.font = [UIFont systemFontOfSize:[YGTools defaultFontSize]];
    self.textViewComment.font = [UIFont systemFontOfSize:[YGTools defaultFontSize]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateUI {
    
    if(self.viewModel.category) {
        if([p_manager hasLinkedObjectsForCategory:self.viewModel.category]) {
            self.cellParentCategory.userInteractionEnabled = NO;
            ;
            self.cellParentCategory.accessoryType = UITableViewCellAccessoryNone;
            self.labelParent.textColor = [YGTools colorForActionDisable];
        } else {
            self.cellParentCategory.userInteractionEnabled = YES;
            self.cellParentCategory.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            self.labelParent.textColor = [UIColor blackColor];
        }
    }
}

#pragma mark - UITextFieldDelegate & UITextViewDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if([textField isEqual:self.textFieldName])
        return [YGTools isValidNameInSourceString:textField.text replacementString:string range:range];
    else if([textField isEqual:self.textFieldSort])
        return [YGTools isValidSortInSourceString:textField.text replacementString:string range:range];
    else
        return NO;
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([textView isEqual:self.textViewComment]) {
        
        if(textView.text && ![textView.text isEqualToString:@""])
            p_comment = textView.text;
        else
            p_comment = nil;
        
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

#pragma mark - Come back from parent category choice

- (IBAction)unwindToExpenseCategoryEdit:(UIStoryboardSegue *)unwindSegue {
    
    YYGExpenseParentChoiceController *vc = unwindSegue.sourceViewController;
    
    if(vc.targetParentCategory) {
        
        self.labelParent.text = [NSString stringWithFormat:@"%@", vc.targetParentCategory.name];
        
        _viewModel.parent = vc.targetParentCategory;
    } else {
        self.labelParent.text = NSLocalizedString(@"ROOT_CATEGORY_LABEL", @"Name of Root category");
        _viewModel.parent = nil;
    }
    
    if(![_viewModel.parent isEqual:_initParentValue]) {
        // UI
        _isParentChanged = YES;
        [self changeSaveButtonEnable];
    }
}

#pragma mark - Monitoring of control value changed

- (IBAction)textFieldNameEditingChanged:(UITextField *)sender {
    
    p_name = self.textFieldName.text;
    
    if([_initNameValue isEqualToString:p_name])
        _isNameChanged = NO;
    else
        _isNameChanged = YES;
    
    if([self.textFieldName.text isEqualToString:@""])
        self.labelName.textColor = [YGTools colorRed];
    else
        self.labelName.textColor = [UIColor blackColor];
    
    [self changeSaveButtonEnable];
}

- (IBAction)textFieldSortEditingChanged:(UITextField *)sender {
    
    p_sort = [self.textFieldSort.text integerValue];
    
    if(_initSortValue == p_sort)
        _isSortChanged = NO;
    else
        _isSortChanged = YES;
    
    if([self.textFieldSort.text isEqualToString:@""])
        self.labelSort.textColor = [YGTools colorRed];
    else
        self.labelSort.textColor = [UIColor blackColor];
    
    [self changeSaveButtonEnable];
}

- (void)textViewDidChange:(UITextView *)textView {
    
    if([textView isEqual:self.textViewComment]) {
        
        p_comment = textView.text;
        
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
    if(_isSortChanged)
        return YES;
    if(_isCommentChanged)
        return YES;
     if(_isParentChanged)
         return YES;
    
    return NO;
}

- (BOOL) isDataReadyForSave {
    
    if(!p_name || [p_name isEqualToString:@""])
        return NO;
    if(p_sort < 1 || p_sort > 999)
        return NO;
    
    return YES;
}

#pragma mark - Change save button enable

- (void) changeSaveButtonEnable {
    if([self isEditControlsChanged] && [self isDataReadyForSave])
        self.navigationItem.rightBarButtonItem.enabled = YES;
    else
        self.navigationItem.rightBarButtonItem.enabled = NO;
}

#pragma mark - Save, deactivate/activate and delete actions

- (void)saveButtonPressed {
    
    p_name = [p_name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    p_comment = [p_comment stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if(p_sort < 1 || p_sort > 999)
        p_sort = 100;
    
    if(self.viewModel.isNew) {
        YGCategory *expenseCategory = [[YGCategory alloc]
                                       initWithType:YGCategoryTypeExpense
                                       name:p_name
                                       sort:p_sort
                                       symbol:nil
                                       attach:NO
                                       parentId:self.viewModel.parent.rowId
                                       comment:p_comment];
        
        [p_manager addCategory:expenseCategory];
    } else {
        if(_isNameChanged)
            self.viewModel.category.name = p_name;
        if(_isSortChanged)
            self.viewModel.category.sort = p_sort;
        if(_isCommentChanged)
            self.viewModel.category.comment = p_comment;
        if(_isParentChanged)
            self.viewModel.category.parentId = self.viewModel.parent.rowId;
        
        self.viewModel.category.modified = [NSDate date];
        
        // change db, not instance
        [p_manager updateCategory:[self.viewModel.category copy]];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)buttonActivatePressed:(UIButton *)sender {
    
    if(self.viewModel.category.active) {
        
        if(![p_manager hasActiveCategoryForTypeExceptCategory:self.viewModel.category]) {
            
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"CAN_NOT_DEACTIVATE_ALERT_TITLE", @"Title of alert Can not deactivate") message:NSLocalizedString(@"CAN_NOT_DEACTIVATE_BECOUSE_APP_NEED_AT_LEAST_ONE_ACTIVE_CATEGORY_FOR_TYPE", @"Message with reason that applicatin must have at least one active category for type") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [controller addAction:actionOk];
            [self presentViewController:controller animated:YES completion:nil];
            
            [self disableButtonActivate];
            
            return;
        }
        
        if([p_manager hasChildObjectActiveForCategory:self.viewModel.category]) {
            
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"CAN_NOT_DEACTIVATE_ALERT_TITLE", @"Title of alert Can not deactivate") message:NSLocalizedString(@"CAN_NOT_DEACTIVATE_BECOUSE_ALL_CHILD_CATEGORIES_MUST_BE_DEACTIVATED", @"Message with reason that all child categories must be deactivated.") preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            
            [controller addAction:actionOk];
            [self presentViewController:controller animated:YES completion:nil];
            
            [self disableButtonActivate];
            
            return;
        }
        
        [p_manager deactivateCategory:self.viewModel.category];
        //[self.buttonActivate setTitle:@"Activate" forState:UIControlStateNormal];
    } else {
        [p_manager activateCategory:self.viewModel.category];
        //[self.buttonActivate setTitle:@"Dectivate" forState:UIControlStateNormal];
    }
    
    // the best way is return to list of categories
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)buttonDeletePressed:(UIButton *)sender {
    
    // check for linked object existens
    if([p_manager hasLinkedObjectsForCategory:self.viewModel.category]) {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"CAN_NOT_DELETE_ALERT_TITLE", @"Title of alert Can not delete") message:NSLocalizedString(@"CAN_NOT_DELETE_BECOUSE_CATEGORY_HAS_LINKED_OBJECTS_MESSAGE", @"Message with reason that category has linked objects (operations, accounts, debts, etc.)") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        
        [controller addAction:actionOk];
        [self presentViewController:controller animated:YES completion:nil];
        
        [self disableButtonDelete];
        
        return;
    }
    
    // check for child objects existens
    if([p_manager hasChildObjectForCategory:self.viewModel.category]) {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"CAN_NOT_DELETE_ALERT_TITLE", @"Title of alert Can not delete") message:NSLocalizedString(@"CAN_NOT_DELETE_BECOUSE_CATEGORY_HAS_CHILD_SUBCATEGORIES_MESSAGE", @"Message with reason that category has child subcategories and to delete the one must delete or split child ones.") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        
        [controller addAction:actionOk];
        [self presentViewController:controller animated:YES completion:nil];
        
        [self disableButtonDelete];
        
        return;
    }
    
    if(![p_manager hasActiveCategoryForTypeExceptCategory:self.viewModel.category]) {
        
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"CAN_NOT_DELETE_ALERT_TITLE", @"Title of alert Can not delete") message:NSLocalizedString(@"REASON_CAN_NOT_DELETE_BECOUSE_ABSENT_ANOTHER_ACTIVE_CATEGORY_FOR_TYPE_MESSAGE", @"Message with reason that category is only one active for type and another is not exists.") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [controller addAction:actionOk];
        [self presentViewController:controller animated:YES completion:nil];
        
        [self disableButtonDelete];
        
        return;
    }
    
    // check for removed category just one
    if([p_manager isJustOneCategory:self.viewModel.category]) {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"CAN_NOT_DELETE_ALERT_TITLE", @"Title of alert Can not delete") message:NSLocalizedString(@"REASON_CAN_NOT_DELETE_BECOUSE_ONLY_ONE_CATEGORY_EXISTS_FOR_TYPE_MESSAGE", @"Message with reason that category is only one for type and can not be deleted.") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        
        [controller addAction:actionOk];
        [self presentViewController:controller animated:YES completion:nil];
        
        [self disableButtonDelete];
        
        return;
    }
    
    // remove category
    [p_manager removeCategory:self.viewModel.category];
    
    // return to Option controller
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)disableButtonDelete {
    self.buttonDelete.enabled = NO;
    self.buttonDelete.backgroundColor = [UIColor lightGrayColor];
    self.buttonDelete.titleLabel.textColor = [UIColor whiteColor];
}

- (void)disableButtonActivate {
    self.buttonActivate.enabled = NO;
    self.buttonActivate.backgroundColor = [UIColor lightGrayColor];
    self.buttonActivate.titleLabel.textColor = [UIColor whiteColor];
}

#pragma mark - Tools

- (NSInteger)sortValueFromString:(NSString *)string {
    
    NSInteger result = 100;
    
    @try {
        if(string && [string length] > 0) {
            result = [string integerValue];
        }
    } @catch (NSException *ex) {
        NSLog(@"Error in -[YGExpenseCategoryEditController sortValueFromString]. Exception: %@", [ex description]);
    } @finally {
        return result;
    }
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    
    // action delete
    if(indexPath.section == 3 && indexPath.row == 1) {
        if(self.viewModel.category) {
            if([p_manager hasLinkedObjectsForCategory:self.viewModel.category]
               || [p_manager hasChildObjectForCategory:self.viewModel.category]
               || ![p_manager hasActiveCategoryForTypeExceptCategory:self.viewModel.category]
               || [p_manager isJustOneCategory:self.viewModel.category]){
                height = 0.0f;
            }
        } else { // for new category
            height = 0.0f;
        }
    }
    
    // action deactivate
    if(indexPath.section == 3 && indexPath.row == 0) {
        if(self.viewModel.category && self.viewModel.category.active) {
            if(![p_manager hasActiveCategoryForTypeExceptCategory:self.viewModel.category]
               || [p_manager hasChildObjectActiveForCategory:self.viewModel.category]) {
                height = 0.0f;
            }
        }
        else if(!self.viewModel.category) {
            height = 0.0f;
        }
    }
    return height;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    YYGExpenseParentChoiceController *vc = segue.destinationViewController;
    vc.expenseCategory = _viewModel.category;
    vc.sourceParentCategory = _viewModel.parent;
}

@end
