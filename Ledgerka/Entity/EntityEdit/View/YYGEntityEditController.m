//
//  YYGEntityEditController.m
//  Ledger
//
//  Created by Ян on 15/06/2017.
//  Modified by Ян on 24/07/2018.
//
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YYGEntityEditController.h"
#import "YGEntityManager.h"
#import "YGCategoryManager.h"
#import "YYGCategorySelectController.h"
#import "YYGCategorySelectViewModel.h"
#import "YGTools.h"
#import "YYGLedgerDefine.h"

@interface YYGEntityEditController () <UITextFieldDelegate, UITextViewDelegate> {
    NSString *p_name;
    NSInteger p_sort;
    NSString *p_comment;
    YGCategory *p_counterparty;
    YYGCounterpartyType p_counterpartyType;
    YGCategory *p_currency;
    BOOL p_isDefault;
    
    // флаги фиксации изменения значений формы
    BOOL _isNameChanged;
    BOOL _isSortChanged;
    BOOL _isCommentChanged;
    BOOL _isCounterpartyChanged;
    BOOL _isCounterpartyTypeChanged;
    BOOL _isCurrencyChanged;
    BOOL _isDefaultChanged;
    
    // первоначальные значения формы, с ними будет идти сравнение для активации кнопки сохранения
    NSString *_initNameValue;
    NSInteger _initSortValue;
    NSString *_initCommentValue;
    YGCategory *_initCounterpartyValue;
    YYGCounterpartyType _initCounterpartyTypeValue;
    YGCategory *_initCurrencyValue;
    BOOL _initIsDefaultValue;
}

@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelSort;
@property (weak, nonatomic) IBOutlet UILabel *labelIsDefault;
@property (weak, nonatomic) IBOutlet UILabel *labelCurrency;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labelsOfController;
@property (weak, nonatomic) IBOutlet UILabel *labelCounterparty;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedCounterpartyType;

@property (weak, nonatomic) IBOutlet UITextField *textFieldName;
@property (weak, nonatomic) IBOutlet UITextField *textFieldSort;
@property (weak, nonatomic) IBOutlet UITextView *textViewComment;

@property (weak, nonatomic) IBOutlet UIButton *buttonActivate;
@property (weak, nonatomic) IBOutlet UIButton *buttonDelete;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttonsOfController;

@property (weak, nonatomic) IBOutlet UITableViewCell *cellSelectCounterparty;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellSelectCounterpartyType;
@property (weak, nonatomic) IBOutlet UISwitch *switchIsDefault;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellSelectCurrency;

@property (weak, nonatomic) IBOutlet UITableViewCell *cellActivate;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellDelete;

- (IBAction)textFieldNameEditingChanged:(UITextField *)sender;
- (IBAction)textFieldSortEditingChanged:(UITextField *)sender;
- (IBAction)switchIsDefaultValueChanged:(UISwitch *)sender;
- (IBAction)segmentedDebtTypeChanged:(UISegmentedControl *)sender;
- (IBAction)buttonActivatePressed:(UIButton *)sender;
- (IBAction)buttonDeletePressed:(UIButton *)sender;

@end

@implementation YYGEntityEditController

- (void)viewDidLoad {
    [super viewDidLoad];

    // UI
    [self setupUI];
    [self setDefaultFontForControls];
    [self updateUI];
}

- (void)setupUI {
    
    // Set title
    self.navigationItem.title = self.viewModel.title;
    
    // Set save button
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed)];
    self.navigationItem.rightBarButtonItem = saveButton;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    // remove empty cells in footer
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    // Text for labels
    self.labelIsDefault.text = [self.viewModel textLabelIsDefault];
    if([self.viewModel hasCounterparty]) {
        [self.segmentedCounterpartyType setTitle:[self.viewModel textSegmentedDebtor] forSegmentAtIndex:0];
        [self.segmentedCounterpartyType setTitle:[self.viewModel textSegmentedCreditor] forSegmentAtIndex:1];
    }
    
    // Add new or edit?
    if(self.viewModel.entity)
        [self fillWith:self.viewModel.entity];
    else
        [self fillWithDefaultValues];

    // Setup internal variables
    [self fillInternals];
}


- (void) fillWithDefaultValues {
    
    // 0. Name
    p_name = nil;
    self.labelName.textColor = [YGTools colorRed];
    
    // 1. Sort
    self.textFieldSort.text = @"100";
    p_sort = 100;
    
    // 2. Counterparty
    p_counterparty = nil;
    if([self.viewModel hasCounterparty]) {
        YGCategory *counterparty = [self.viewModel defaultCounterparty];
        if(counterparty) {
            p_counterparty = counterparty;
            self.labelCounterparty.text = p_counterparty.name;
            if([self.viewModel isOnlyOneActive:p_counterparty]) {
                self.cellSelectCounterparty.accessoryType = UITableViewCellAccessoryNone;
                self.cellSelectCounterparty.userInteractionEnabled = NO;
                self.labelCounterparty.textColor = [UIColor grayColor];
            }
        }
    }
    
    p_counterpartyType = YYGCounterpartyTypeDebtor;
    self.segmentedCounterpartyType.selectedSegmentIndex = p_counterpartyType - 1;
    
    self.switchIsDefault.on = NO;
    p_isDefault = NO;
    
    p_comment = nil;
    // имитируем placeholder у textView
    self.textViewComment.text = NSLocalizedString(@"TEXT_VIEW_COMMENT_PLACEHOLDER", @"Placeholder for all textView for comments.");
    self.textViewComment.textColor = [UIColor lightGrayColor];
    self.textViewComment.delegate = self;
    
    // hide button activate
    self.buttonActivate.enabled = NO;
    self.buttonActivate.hidden = YES;
    
    // hide button delete
    self.buttonDelete.enabled = NO;
    self.buttonDelete.hidden = YES;
    
    YGCategory *currency = [self.viewModel defaultCurrency];
    
    if(currency) {
        p_currency = currency;
        self.labelCurrency.text = p_currency.name;
    } else {
        p_currency = nil;
        self.labelCurrency.text = NSLocalizedString(@"SELECT_CURRENCY_LABEL", @"Select currency text on label.");
        self.labelCurrency.textColor = [YGTools colorRed];
    }
    
    // фокус на поле ввода наименования с небольшой задержкой, чтобы клавиатура появлялась более плавно
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kKeyboardAppearanceDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.textFieldName becomeFirstResponder];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    });

}

- (void)fillWith:(YGEntity *)entity {
    
    // 0. Name
    self.textFieldName.text = entity.name;
    p_name = entity.name;
    
    // 1. Sort
    self.textFieldSort.text = [NSString stringWithFormat:@"%ld", (long)entity.sort];
    p_sort = self.viewModel.entity.sort;
    
    // 2,3. Counterparty & debt type
    if([self.viewModel hasCounterparty]) {
        p_counterparty = [self.viewModel counterpartyOf:entity];
        self.labelCounterparty.text = p_counterparty.name;
        if([self.viewModel isOnlyOneActive:p_counterparty]) {
            self.cellSelectCounterparty.accessoryType = UITableViewCellAccessoryNone;
            self.cellSelectCounterparty.userInteractionEnabled = NO;
            self.labelCounterparty.textColor = [UIColor grayColor];
        }
        
        p_counterpartyType = entity.counterpartyType;
        self.segmentedCounterpartyType.selectedSegmentIndex = p_counterpartyType - 1;
    }
    
    // 4. Currency
    p_currency = [self.viewModel currencyOf:entity];
    self.labelCurrency.text = p_currency.name;
    
    // 5. Is default
    self.switchIsDefault.on = entity.attach;
    p_isDefault = entity.attach;
    
    // 6. Comment
    p_comment = entity.comment;
    // если комментария нет, то имитируем placeholder
    if(p_comment && ![p_comment isEqualToString:@""]) {
        self.textViewComment.text = p_comment;
        self.textViewComment.textColor = [UIColor blackColor];
    } else {
        self.textViewComment.text = NSLocalizedString(@"TEXT_VIEW_COMMENT_PLACEHOLDER", @"Placeholder for all textView for comments.");
        self.textViewComment.textColor = [UIColor lightGrayColor];
    }
    //self.textViewComment.delegate = self;

    // 7. Activate
    self.buttonActivate.enabled = YES;
    if(entity.active) {
        [self.buttonActivate setTitle: NSLocalizedString(@"DEACTIVATE_BUTTON_TITLE", @"Deactivate for button title") forState:UIControlStateNormal];
        self.buttonActivate.backgroundColor = [YGTools colorForActionDeactivate];
    } else {
        [self.buttonActivate setTitle:NSLocalizedString(@"ACTIVATE_BUTTON_TITLE", @"Activate for button title") forState:UIControlStateNormal];
        self.buttonActivate.backgroundColor = [YGTools colorForActionActivate];
    }
    
    // 8. Delete?
}

- (void)fillInternals {
    
    // init state for user changes
    _isNameChanged = NO;
    _isSortChanged = NO;
    _isCommentChanged = NO;
    _isCounterpartyChanged = NO;
    _isCounterpartyTypeChanged = NO;
    _isCurrencyChanged = NO;
    _isDefaultChanged = NO;
    
    // init state of UI
    _initNameValue = p_name;
    _initSortValue = p_sort;
    _initCommentValue = p_comment;
    _initCounterpartyValue = [p_counterparty copy];
    _initCounterpartyTypeValue = p_counterpartyType;
    _initCurrencyValue = [p_currency copy];
    _initIsDefaultValue = p_isDefault;
    
    // set delegate to self for validators
    self.textFieldName.delegate = self;
    self.textFieldSort.delegate = self;
    self.textViewComment.delegate = self;
}

- (void)setDefaultFontForControls {
    
    // set font size of labels
    for(UILabel *label in self.labelsOfController) {
        
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:[YGTools defaultFontSize]], NSForegroundColorAttributeName:label.textColor};
        
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self updateUI];
}

/**
 Update UI for enable or disable some controls. DataSource for this controls may changed outside.
 */
- (void)updateUI {
    
    // Can change category counterparty?
    if([self.viewModel hasCounterparty]) {
        if([self.viewModel canChangeCounterparty]) {
            self.cellSelectCounterparty.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            self.cellSelectCounterparty.userInteractionEnabled = YES;
            self.labelCounterparty.textColor = [UIColor blackColor];
        } else {
            self.cellSelectCounterparty.accessoryType = UITableViewCellAccessoryNone;
            self.cellSelectCounterparty.userInteractionEnabled = NO;
            self.labelCounterparty.textColor = [UIColor grayColor];
        }
    }
    
    // Can change debtType?
    if([self.viewModel hasCounterparty])
        self.segmentedCounterpartyType.userInteractionEnabled = [self.viewModel canChangeCounterpartyType];
    
    // Color invite to select?
    if([self.viewModel hasCounterparty] && !p_counterparty) {
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:[YGTools defaultFontSize]], NSForegroundColorAttributeName:[YGTools colorRed]};
        NSAttributedString *attributed = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"ENTITY_EDIT_FORM_SELECT_COUNTERPARTY_LABEL", @"Select counterparty text on label") attributes:attributes];
        self.labelCounterparty.attributedText = attributed;
    }
    
    // Can change currency?
    if([self.viewModel canChangeCurrency]) {
        self.cellSelectCurrency.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.cellSelectCurrency.userInteractionEnabled = YES;
        self.labelCurrency.textColor = [UIColor blackColor];
    } else {
        self.cellSelectCurrency.accessoryType = UITableViewCellAccessoryNone;
        self.cellSelectCurrency.userInteractionEnabled = NO;
        self.labelCurrency.textColor = [UIColor grayColor];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        return [YGTools isValidCommentInSourceString:textView.text replacementString:text range:range];
    }
    else
        return NO;
}

#pragma mark - Warnings

- (void)showWarningOfSaveDuplicateAccount {
    
    UIAlertController *warningController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ATTENTION_ALERT_CONTROLLER_TITLE", @"Attention title of alert controller") message:NSLocalizedString(@"ACCOUNT_DUPLICATE_SAVE_WARNING_MESSAGE", @"Message in warning in saving duplicated account") preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    
    [warningController addAction:okAction];
    [self presentViewController:warningController animated:YES completion:nil];
}

#pragma mark - UITextViewDelegate for placeholder

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

#pragma mark - Monitoring of control value changed

- (IBAction)textFieldNameEditingChanged:(UITextField *)sender {
    
    if([sender isEqual:self.textFieldName]) {
        p_name = self.textFieldName.text;
        
        if([self.textFieldName.text isEqualToString:@""])
            self.labelName.textColor = [YGTools colorRed];
        else
            self.labelName.textColor = [UIColor blackColor];
        
        if([_initNameValue isEqualToString:p_name])
            _isNameChanged = NO;
        else
            _isNameChanged = YES;
        [self changeSaveButtonEnable];
    }
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
    
    if([textView isEqual:self.textViewComment]){
        
        p_comment = textView.text;
        
        if([_initCommentValue isEqualToString:p_comment])
            _isCommentChanged = NO;
        else
            _isCommentChanged = YES;
        
        [self changeSaveButtonEnable];
    }
}

- (IBAction)switchIsDefaultValueChanged:(UISwitch *)sender {
    if([sender isEqual:self.switchIsDefault]) {
        p_isDefault = self.switchIsDefault.isOn;
        if(_initIsDefaultValue == p_isDefault)
            _isDefaultChanged = NO;
        else
            _isDefaultChanged = YES;
        [self changeSaveButtonEnable];
    }
}

- (IBAction)segmentedDebtTypeChanged:(UISegmentedControl *)sender {    
    if([sender isEqual:self.segmentedCounterpartyType]) {
        p_counterpartyType = sender.selectedSegmentIndex + 1;
        if(_initCounterpartyTypeValue == p_counterpartyType)
            _isCounterpartyTypeChanged = NO;
        else
            _isCounterpartyTypeChanged = YES;
        [self changeSaveButtonEnable];
    }
}

#pragma mark - Monitor controls values changed

- (BOOL)isEditControlsChanged {
    
    if(_isNameChanged || _isSortChanged || _isCounterpartyChanged || _isCounterpartyTypeChanged || _isCurrencyChanged || p_isDefault || _isCommentChanged)
        return YES;
    else
        return NO;
}


- (BOOL)isDataReadyForSave {
    
    if(!p_name || [p_name isEqualToString:@""])
        return NO;
    if([self.viewModel hasCounterparty] && !p_counterparty)
        return NO;
    if(!p_currency)
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
    if(self.viewModel.type == YGEntityTypeDebt && ![self.viewModel hasAccountWithCurrencyId:p_currency.rowId]) {
        [self alertAboutAccountWithSameCurrencyOn:^{
            [self saveEntity];
            [self.navigationController popViewControllerAnimated:YES];
        }];
    } else {
        [self saveEntity];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)alertAboutAccountWithSameCurrencyOn:(void(^)(void))handler {
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ALERT_CONTROLLER_WARNING_TITLE", @"Alert controller warning title") message:NSLocalizedString(@"ALERT_CONTROLLER_NEEDS_SAME_CURRENCY_MESSAGE", @"Alert controller needs same currency message") preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        handler();
    }];
    [alertVC addAction:okButton];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)saveEntity {
    // удаляем пробелы, окружающие строки
    p_name = [p_name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    p_comment = [p_comment stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if(p_sort < 1 || p_sort > 999)
        p_sort = 100;
    
    if(!self.viewModel.entity) {
        
        YGEntity *entity = [[YGEntity alloc]
                            initWithType:self.viewModel.type
                            name:p_name
                            sum:0.0f
                            currencyId:p_currency.rowId
                            attach:p_isDefault
                            sort:p_sort
                            comment:p_comment
                            counterpartyId:[self.viewModel hasCounterparty] ? p_counterparty.rowId : -1
                            counterpartyType:[self.viewModel hasCounterparty] ? p_counterpartyType : -1
                            ];
        
        // проверка на попытку сохранения дублирующего счета, т.е. счета с разным id, но одинаковыми названием и id валюты
        if([self.viewModel isExistLinkedOperationsWith:entity]){
            self.navigationItem.rightBarButtonItem.enabled = NO;
            [self showWarningOfSaveDuplicateAccount];
            return;
        }
        
        [self.viewModel add:entity]; // ранее было copy?
    } else {
        
        // проверка на попытку сохранения дублирующего счета, т.е. счета с разным id, но одинаковыми названием и id валюты
        if([self.viewModel isExistDuplicateOf:self.viewModel.entity]) {
            self.navigationItem.rightBarButtonItem.enabled = NO;
            [self showWarningOfSaveDuplicateAccount];
            return;
        }
        
        if(_isNameChanged)
            self.viewModel.entity.name = p_name;
        if(_isSortChanged)
            self.viewModel.entity.sort = p_sort;
        if(_isCounterpartyChanged)
            self.viewModel.entity.counterpartyId = p_counterparty.rowId;
        if(_isCounterpartyTypeChanged)
            self.viewModel.entity.counterpartyType = p_counterpartyType;
        if(_isCommentChanged)
            self.viewModel.entity.comment = p_comment;
        if(_isCurrencyChanged)
            self.viewModel.entity.currencyId = p_currency.rowId;
        if(_isDefaultChanged)
            self.viewModel.entity.attach = p_isDefault;
        
        self.viewModel.entity.modified = [NSDate date];
        
        // change db, not instance
        [self.viewModel update:self.viewModel.entity]; // ранее было copy?
    }
}

- (IBAction)buttonActivatePressed:(UIButton *)sender {
    if(self.viewModel.entity){
        if(self.viewModel.entity.active){
            [self.viewModel deactivate:self.viewModel.entity];
        } else {
            [self.viewModel activate:self.viewModel.entity];
        }
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)buttonDeletePressed:(UIButton *)sender {
    if([self.viewModel isExistLinkedOperationsWith:self.viewModel.entity]) {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"CAN_NOT_DELETE_ALERT_TITLE", @"Title of alert Can not delete") message:NSLocalizedString(@"REASON_CAN_NOT_DELETE_ACCOUNT_WITH_LINKED_MESSAGE", @"Message with reason that current account has linked objects and can not be deleted.") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [controller addAction:actionOk];
        [self presentViewController:controller animated:YES completion:nil];
    } else {
        [self.viewModel remove:self.viewModel.entity];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    YYGCategorySelectController *vc = segue.destinationViewController;
    
    if([segue.identifier isEqualToString:@"CounterpartySelectFromEntityEditSegue"]) {
        vc.viewModel = [YYGCategorySelectViewModel viewModelWith:YGCategoryTypeCounterparty];
        vc.viewModel.source = p_counterparty;
    }
    else if ([segue.identifier isEqualToString:@"CurrencySelectFromEntityEditSegue"]) {
        vc.viewModel = [YYGCategorySelectViewModel viewModelWith:YGCategoryTypeCurrency];
        vc.viewModel.source = p_currency;
    }
}

- (IBAction)unwindFromCategorySelectToEntityEdit:(UIStoryboardSegue *)unwindSegue {
    
    YYGCategorySelectController *vc = unwindSegue.sourceViewController;
    
    // If select is done
    if(vc.viewModel.target) {
        if([unwindSegue.identifier isEqualToString:@"unwindFromCounterpartySelectToEntityEdit"]) {
            
            p_counterparty = vc.viewModel.target;
            
            // Update UI
            NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:[YGTools defaultFontSize]],NSForegroundColorAttributeName:[UIColor blackColor],};
            NSAttributedString *attributed = [[NSAttributedString alloc] initWithString:p_counterparty.name attributes:attributes];
            self.labelCounterparty.attributedText = attributed;
            
            if([p_counterparty isEqual:_initCounterpartyValue])
                _isCounterpartyChanged = NO;
            else
                _isCounterpartyChanged = YES;
            [self changeSaveButtonEnable];
        }
        else if([unwindSegue.identifier isEqualToString:@"unwindFromCurrencySelectToEntityEdit"]) {
            
            p_currency = vc.viewModel.target;
            
            // Update UI
            NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:[YGTools defaultFontSize]],NSForegroundColorAttributeName:[UIColor blackColor],};
            NSAttributedString *attributed = [[NSAttributedString alloc] initWithString:p_currency.name attributes:attributes];
            self.labelCurrency.attributedText = attributed;

            if([p_currency isEqual:_initCurrencyValue])
                _isCurrencyChanged = NO;
            else
                _isCurrencyChanged = YES;
            [self changeSaveButtonEnable];
        } else {
            @throw [NSException exceptionWithName:@"YYGEntityEditController.unwindFromCategorySelectToEntityEdit fails" reason:@"Unknown unwind segue." userInfo:nil];
        }
    }
}

#pragma mark - Data source methods to show/hide action cells

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    
    switch(indexPath.section){
        case 1: // counterparty choice cell
            if(![self.viewModel showCounterpartyAndTypeSection])
                height = 0.0f;
            break;
        case 3: // Defaults section
            if(![self.viewModel showDefaultSection])
                height = 0.0f;
            break;
        case 5: // activate & delete buttons
            if(!self.viewModel.entity
               || (self.viewModel.entity && indexPath.row == 1 && ![self.viewModel canDelete])
               || (self.viewModel.entity && indexPath.row == 0 && ![self.viewModel currencyOf:self.viewModel.entity].active))
                height = 0.0f;
            break;
    }
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    CGFloat height = [super tableView:tableView heightForHeaderInSection:section];
    
    switch(section) {
        case 1:
            if(![self.viewModel showCounterpartyAndTypeSection])
                height = 1.0f;
            break;
        case 3: // Defaults section
            if(![self.viewModel showDefaultSection])
                height = 1.0f;
            break;
    }
    
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *footerView = [super tableView:tableView viewForHeaderInSection:section];
    
    switch (section) {
        case 1:
            if(![self.viewModel showCounterpartyAndTypeSection])
                footerView = [[UIView alloc] initWithFrame:CGRectZero];
            break;
        case 3: // Defaults section
            if(![self.viewModel showDefaultSection])
                footerView = [[UIView alloc] initWithFrame:CGRectZero];;
            break;
    }
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    CGFloat height = [super tableView:tableView heightForFooterInSection:section];
    
    switch(section) {
        case 1:
            if(![self.viewModel showCounterpartyAndTypeSection])
                height = 1.0f;
            break;
        case 3: // Defaults section
            if(![self.viewModel showDefaultSection])
                height = 1.0f;
            break;
    }
    
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    UIView *footerView = [super tableView:tableView viewForFooterInSection:section];
    
    switch (section) {
        case 1:
            if(![self.viewModel showCounterpartyAndTypeSection])
                footerView = [[UIView alloc] initWithFrame:CGRectZero];
            break;
        case 3: // Defaults section
            if(![self.viewModel showDefaultSection])
                footerView = [[UIView alloc] initWithFrame:CGRectZero];;
            break;
    }
    return footerView;
}

@end
