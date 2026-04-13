//
//  YYGOperationEditController.m
//  Ledger
//
//  Created by Ян on 04.08.2018.
//  Copyright © 2018 Yan Gerasimuk. All rights reserved.
//

#import "YYGOperationEditController.h"
#import "YYGOperationEditViewModel.h"
#import "YGTools.h"
#import "YYGLedgerDefine.h"
#import "YYGObject.h"
#import "YGDateChoiceController.h"
#import "YYGCategorySelectController.h"
#import "YYGEntitySelectController.h"
#import "YGCategory.h"

@interface YYGOperationEditController () <UITextFieldDelegate, UITextViewDelegate> {
    
    NSDate *p_day;
    id<YYGRowIdAndNameIdentifiable> p_source; // Source may be category or entity
    double p_sourceSum;
    YGCategory *p_sourceCurrency;
    id<YYGRowIdAndNameIdentifiable> p_target; // Target may be category or entity
    double p_targetSum;
    YGCategory *p_targetCurrency;
    NSString *p_comment;
    
    // Change flags
    BOOL p_isDayChanged, p_isSourceChanged, p_isSourceSumChanged, p_isTargetChanged, p_isTargetSumChanged, p_isCommentChanged;
    
    // Initial values
    NSDate *p_dayInitValue;
    id<YYGRowIdAndNameIdentifiable> p_sourceInitValue;
    double p_sourceSumInitValue;
    id<YYGRowIdAndNameIdentifiable> p_targetInitValue;
    double p_targetSumInitValue;
    NSString *p_commentInitValue;
}

// Cells
@property (weak, nonatomic) IBOutlet UITableViewCell *cellDate;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellSource;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellSourceSum;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellTarget;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellTargetSum;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellComment;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellDelete;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellSaveAndAdd;

// Labels
@property (weak, nonatomic) IBOutlet UILabel *labelDate;
@property (weak, nonatomic) IBOutlet UILabel *labelSource;
@property (weak, nonatomic) IBOutlet UILabel *labelSourceSumHeader;
@property (weak, nonatomic) IBOutlet UILabel *labelSourceCurrency;
@property (weak, nonatomic) IBOutlet UILabel *labelTarget;
@property (weak, nonatomic) IBOutlet UILabel *labelTargetSumHeader;
@property (weak, nonatomic) IBOutlet UILabel *labelTargetCurrency;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labelsOfController;

// Text edit
@property (weak, nonatomic) IBOutlet UITextField *textFieldSourceSum;
@property (weak, nonatomic) IBOutlet UITextField *textFieldTargetSum;
@property (weak, nonatomic) IBOutlet UITextView *textViewComment;

// Buttons
@property (weak, nonatomic) IBOutlet UIButton *buttonDelete;
@property (weak, nonatomic) IBOutlet UIButton *buttonSaveAndAdd;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttonsOfController;

// Actions
- (IBAction)buttonDeletePressed:(UIButton *)sender;
- (IBAction)buttonSaveAndAddPressed:(UIButton *)sender;
- (IBAction)textFieldEditingChanged:(UITextField *)sender;
@end

@implementation YYGOperationEditController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    if(self.viewModel.operation)
        [self fillWith:self.viewModel.operation];
    else
        [self fillWithDefaultValues];
    
    [self setDefaultFontForControls];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setupUI {
    
    // UI
    self.title = [self.viewModel title];
    
    // button save
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed)];
    
    self.navigationItem.rightBarButtonItem = saveButton;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    // init state for monitor user changes
    p_isDayChanged = NO;
    p_isSourceChanged = NO;
    p_isSourceSumChanged = NO;
    p_isTargetChanged = NO;
    p_isTargetSumChanged = NO;
    p_isCommentChanged = NO;
    
    self.textFieldSourceSum.delegate = self;
    self.textFieldTargetSum.delegate = self;
    self.textViewComment.delegate = self;
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
    
    self.textFieldSourceSum.font = [UIFont systemFontOfSize:[YGTools defaultFontSize]];
    self.textFieldTargetSum.font = [UIFont systemFontOfSize:[YGTools defaultFontSize]];
    self.textViewComment.font = [UIFont systemFontOfSize:[YGTools defaultFontSize]];
}

- (void)fillWithDefaultValues {
    
    // 0.0. Set date
    p_day = [YGTools dayOfDate:[NSDate date]];
    self.labelDate.text = [YGTools humanViewWithTodayOfDate:p_day];
    
    // 1.0. & 1.1. Set source and sum
    if([self.viewModel showSource]) {
        p_source = [self.viewModel defaultSource];
        p_sourceSum = 0.0f;
        if(p_source) {
            // TODO: dont assign p_sourceCurrency inside this funcs
            [self updateUIWithSource:p_source operation:nil];
        } else {
            p_sourceCurrency = nil;
            [self updateUIWithUnknownSource];
        }
    } else {
        self.cellSource.hidden = YES;
        self.cellSourceSum.hidden = YES;
    }
    
    // 1.2. & 1.3. Set target and sum
    if([self.viewModel showTarget]) {
        p_target = [self.viewModel defaultTarget];
        p_targetSum = 0.0f;
        if(p_target) {
            [self updateUIWithTarget:p_target operation:nil];
        } else {
            p_targetCurrency = nil;
            [self updateUIWithUnknownTarget];
        }
    } else {
        self.cellTarget.hidden = YES;
        self.cellTargetSum.hidden = YES;
    }

    // 2.0. имитируем placeholder у textView
    self.textViewComment.text = NSLocalizedString(@"TEXT_VIEW_COMMENT_PLACEHOLDER", @"Placeholder for all textView for comments.");
    self.textViewComment.textColor = [UIColor lightGrayColor];
    
    // 3.0. Delete button
    self.cellDelete.hidden = YES;
    self.buttonDelete.hidden = YES;
    self.buttonDelete.enabled = NO;
    
    // 3.1. Save and add new button
    self.cellSaveAndAdd.hidden = NO;
    self.buttonSaveAndAdd.hidden = NO;
    self.buttonSaveAndAdd.enabled = YES;
    self.buttonSaveAndAdd.backgroundColor = [YGTools colorForActionSaveAndAddNew];
    
    // Init
    p_dayInitValue = [p_day copy];
    p_sourceInitValue = nil;
    p_sourceSumInitValue = 0.0f;
    p_targetInitValue = nil;
    p_targetSumInitValue = 0.0f;
    p_commentInitValue = nil;
    
    // Set focus on sum only for all modes
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kKeyboardAppearanceDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if([self.viewModel showSourceSum])
            [self.textFieldSourceSum becomeFirstResponder];
        else if([self.viewModel showTargetSum])
            [self.textFieldTargetSum becomeFirstResponder];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    });
}

- (void)fillWith:(YGOperation *)operation {
    
    // 0.0. Date
    p_day = [operation.day copy];
    self.labelDate.text = [YGTools humanViewWithTodayOfDate:p_day];
    
    // 1.0 & 1.1. Source and sum
    p_sourceSum = operation.sourceSum;
    if([self.viewModel showSource]) {
        p_source = [self.viewModel sourceOf:operation];
        if([self.viewModel showSourceSum]) {
            p_sourceSum = operation.sourceSum;
            self.textFieldSourceSum.text = [YGTools stringCurrencyFromDouble:p_sourceSum];
        }
        if(p_source)
            [self updateUIWithSource:p_source operation:self.viewModel.operation];
    }
    
    // 1.2 & 1.3. Target and sum
    p_targetSum = operation.targetSum;
    if([self.viewModel showTarget]) {
        p_target = [self.viewModel targetOf:operation];
        if([self.viewModel showTargetSum]) {
            p_targetSum = operation.targetSum;
            self.textFieldTargetSum.text = [YGTools stringCurrencyFromDouble:p_targetSum];
        }
        if(p_target)
            [self updateUIWithTarget:p_target operation:operation];
    }
    
    // 2.0. Comment
    p_comment = [operation.comment copy];
    // если комментария нет, то имитируем placeholder
    if(p_comment && ![p_comment isEqualToString:@""]){
        self.textViewComment.text = p_comment;
        self.textViewComment.textColor = [UIColor blackColor];
    } else {
        self.textViewComment.text = NSLocalizedString(@"TEXT_VIEW_COMMENT_PLACEHOLDER", @"Placeholder for all textView for comments.");
        self.textViewComment.textColor = [UIColor lightGrayColor];
    }
    
    // 3.0. Delete button
    self.cellDelete.hidden = NO;
    self.buttonDelete.hidden = NO;
    self.buttonDelete.enabled = YES;
    self.buttonDelete.backgroundColor = [YGTools colorForActionDelete];
    
    // 3.1. Save and add new button
    self.cellSaveAndAdd.hidden = YES;
    self.buttonSaveAndAdd.hidden = YES;
    self.buttonSaveAndAdd.enabled = NO;
    
    // Init values
    p_dayInitValue = [p_day copy];
    p_sourceInitValue = [p_source copyWithZone:nil];
    p_sourceSumInitValue = p_sourceSum;
    p_targetInitValue = [p_target copyWithZone:nil];
    p_targetSumInitValue = p_targetSum;
    p_commentInitValue = [p_comment copy];
}

#pragma mark - Update some UI

- (void)updateUIWithSource:(id<YYGRowIdAndNameIdentifiable>)source operation:(YGOperation *)operation {
    
    // Prepare text
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:[YGTools defaultFontSize]],NSForegroundColorAttributeName:[UIColor blackColor],};
    NSAttributedString *attributed = [[NSAttributedString alloc] initWithString:source.name attributes:attributes];
    self.labelSource.attributedText = attributed;
    
    // Check and prepare sum & currency
    if([self.viewModel hasSumAndCurrency:p_source]) {
        p_sourceCurrency = [self.viewModel currencyOf:(id<YYGSumAndCurrencyIdentifiable>)p_source];
        self.labelSourceCurrency.text = [p_sourceCurrency shorterName];
        self.labelSourceCurrency.textColor = [UIColor blackColor];
        
        if(((id<YYGSumAndCurrencyIdentifiable>)p_source).sum > 0.0f) {
            self.labelSourceSumHeader.attributedText = [YGTools attributedStringWithText:[NSString stringWithFormat:@"%@", NSLocalizedString(@"SUM", "Sum.")] color:[UIColor blackColor]];
        } else {
            self.labelSourceSumHeader.attributedText = [YGTools attributedStringWithText:[NSString stringWithFormat:@"%@", NSLocalizedString(@"SUM", "Sum.")] color:[YGTools colorRed]];
        }
    }
    
    // Check select possibility and color controls
    if([self.viewModel isOnlyChoiceSource]) {
        self.labelSource.textColor = [UIColor grayColor];
        self.cellSource.userInteractionEnabled = NO;
        self.cellSource.accessoryType = UITableViewCellAccessoryNone;
    } else {
        self.labelSource.textColor = [UIColor blackColor];
        self.cellSource.userInteractionEnabled = YES;
        self.cellSource.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
}

- (void)updateUIWithUnknownSource {
    self.labelSource.text = [self.viewModel textSelectSource];
    self.labelSource.textColor = [YGTools colorRed];
    self.labelSourceSumHeader.attributedText = [YGTools attributedStringWithText:[NSString stringWithFormat:@"%@", NSLocalizedString(@"SUM", "Sum.")] color:[YGTools colorRed]];
    self.labelSourceCurrency.text = @"?";
    self.labelSourceCurrency.textColor = [YGTools colorRed];
}

- (void)checkTermsAndEnableSaveWithSource:(id<YYGRowIdAndNameIdentifiable>)source {
    if([source isEqual:p_sourceInitValue])
        p_isSourceChanged = NO;
    else
        p_isSourceChanged = YES;
    [self checkTermsAndEnableSave];
}

- (void)updateUIWithTarget:(id<YYGRowIdAndNameIdentifiable>)target operation:(YGOperation *)operation {
    
    // Prepare text
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:[YGTools defaultFontSize]],NSForegroundColorAttributeName:[UIColor blackColor],};
    NSAttributedString *attributed = [[NSAttributedString alloc] initWithString:target.name attributes:attributes];
    self.labelTarget.attributedText = attributed;
    
    // Check and prepare sum & currency
    if([self.viewModel hasSumAndCurrency:p_target]) {
        p_targetCurrency = [self.viewModel currencyOf:(id<YYGSumAndCurrencyIdentifiable>)p_target];
        self.labelTargetCurrency.text = [p_targetCurrency shorterName];
        self.labelTargetCurrency.textColor = [UIColor blackColor];
        
        if(((id<YYGSumAndCurrencyIdentifiable>)p_target).sum > 0.0f) {
            self.labelTargetSumHeader.attributedText = [YGTools attributedStringWithText:[NSString stringWithFormat:@"%@", NSLocalizedString(@"SUM", "Sum.")] color:[UIColor blackColor]];
        } else {
            self.labelTargetSumHeader.attributedText = [YGTools attributedStringWithText:[NSString stringWithFormat:@"%@", NSLocalizedString(@"SUM", "Sum.")] color:[YGTools colorRed]];
        }
    }

    // Check select possibility and color controls
    if([self.viewModel isOnlyChoiceTarget]) {
        self.labelTarget.textColor = [UIColor grayColor];
        self.cellTarget.userInteractionEnabled = NO;
        self.cellTarget.accessoryType = UITableViewCellAccessoryNone;
    } else {
        self.labelTarget.textColor = [UIColor blackColor];
        self.cellTarget.userInteractionEnabled = YES;
        self.cellTarget.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
}

- (void)updateUIWithUnknownTarget {
    self.labelTarget.text = [self.viewModel textSelectTarget];
    self.labelTarget.textColor = [YGTools colorRed];
    self.labelTargetSumHeader.attributedText = [YGTools attributedStringWithText:[NSString stringWithFormat:@"%@", NSLocalizedString(@"SUM", "Sum.")] color:[YGTools colorRed]];
    self.labelTargetCurrency.text = @"?";
    self.labelTargetCurrency.textColor = [YGTools colorRed];
}

- (void)checkTermsAndEnableSaveWithTarget:(id<YYGRowIdAndNameIdentifiable>)target {
    if([target isEqual:p_targetInitValue])
        p_isTargetChanged = NO;
    else
        p_isTargetChanged = YES;
    [self checkTermsAndEnableSave];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.viewModel numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.viewModel numberOfRowsInSection:section];
}

#pragma mark - UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.viewModel titleForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.viewModel heightForRow:indexPath.row inSection:indexPath.section];
}

#pragma mark - Navigation

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if([self.viewModel isSelectableRowAt:indexPath.row inSection:indexPath.section]) {
        UIViewController <YYGViewModelable> *vc = [self.storyboard instantiateViewControllerWithIdentifier:[self.viewModel selectSchemeNameForRow:indexPath.row inSection:indexPath.section]];
        
        YGOperationType type = self.viewModel.type;
        if(type == YGOperationTypeIncome || type == YGOperationTypeExpense || type == YGOperationTypeAccountActual || type == YGOperationTypeTransfer || type == YGOperationTypeSetDebt) {
            vc.viewModel = [self.viewModel selectViewModelForRow:indexPath.row inSection:indexPath.section];
        }
        else if(type == YGOperationTypeGiveDebt || type == YGOperationTypeRepaymentDebt || type == YGOperationTypeGetCredit || type == YGOperationTypeReturnCredit) {
            
            YGCategory *supposedCurrency;
            if(indexPath.row == 0 && indexPath.section == 1) // inverse source currency
                supposedCurrency = p_targetCurrency;
            else if(indexPath.row == 2 && indexPath.section == 1) // inverse target currency
                supposedCurrency = p_sourceCurrency;
            
            vc.viewModel = [self.viewModel selectViewModelForRow:indexPath.row inSection:indexPath.section supposedCurrency:supposedCurrency];
        } else {
            @throw [NSException exceptionWithName:@"YYGOperationEditController tableView:didSelectRowAtIndexPath: fails." reason:@"Unknown operation type." userInfo:nil];
        }
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if([segue.identifier isEqualToString:@"segueFromOperationEditToDateChoice"]) {
        YGDateChoiceController *vc = segue.destinationViewController;
        vc.sourceDate = [p_day copy];
        vc.customer = YGDateChoiceCustomerOperation;
    }
}

# pragma mark - Navigation callbacks

- (IBAction)unwindFromDateChoiceToOperationEdit:(UIStoryboardSegue *)unwindSegue {
    
    YGDateChoiceController *vc = unwindSegue.sourceViewController;
    
    p_day = [YGTools dayOfDate:vc.targetDate];
    
    self.labelDate.attributedText = [YGTools attributedStringWithText:[YGTools humanViewWithTodayOfDate:p_day] color:[UIColor blackColor]];
    
    if([YGTools isDayOfDate:p_day equalsDayOfDate:p_dayInitValue])
        p_isDayChanged = NO;
    else
        p_isDayChanged = YES;
    
    [self checkTermsAndEnableSave];
}

- (IBAction)unwindFromCategorySelectToOperationEdit:(UIStoryboardSegue *)unwindSegue {
    YYGCategorySelectController *vc = unwindSegue.sourceViewController;
    if([unwindSegue.identifier isEqualToString:@"unwindFromSourceCategorySelectToOperationEdit"]) {
        p_source = vc.viewModel.source;
        [self updateUIWithSource:p_source operation:self.viewModel.operation];
        [self checkTermsAndEnableSaveWithSource:p_source];
    } else if([unwindSegue.identifier isEqualToString:@"unwindFromTargetCategorySelectToOperationEdit"]) {
        p_target = vc.viewModel.target;
        [self updateUIWithTarget:p_target operation:self.viewModel.operation];
        [self checkTermsAndEnableSaveWithTarget:p_target];
    } else {
        @throw [NSException exceptionWithName:@"YYGOperationEditController unwindFromCategorySelectToOperationEdit fails." reason:@"Unknown unwind segue name." userInfo:nil];
    }
}

- (IBAction)unwindFromEntitySelectToOperationEdit:(UIStoryboardSegue *)unwindSegue {
    YYGEntitySelectController *vc = unwindSegue.sourceViewController;
    if([unwindSegue.identifier isEqualToString:@"unwindFromSourceEntitySelectToOperationEdit"]) {
        if(vc.viewModel.target) {
            p_source = vc.viewModel.target;
            // p_sourceCurrency обновляется в следующей строке
            [self updateUIWithSource:p_source operation:self.viewModel.operation];
            
            // Первая развилка - делать вообще проверку на соответствие валюты или нет?
            // Для долговых операций делаем, для других - нет?
            if([self.viewModel checkPiredForSameCurrency]) {
                
                // Если есть Цель, то проверяем её на соответствие валюте Источника
                // И на всякий случай, есть ли там вообще валюта
                if(p_target
                   && [[p_target class] conformsToProtocol:@protocol(YYGSumAndCurrencyIdentifiable)]) {
                    
                    id<YYGSumAndCurrencyIdentifiable> objectWithCurrency = (id<YYGSumAndCurrencyIdentifiable>)p_target;
                    if(objectWithCurrency.currencyId != p_sourceCurrency.rowId) {
                        [self guessDefaultTargetFor:p_source initIfFalse:YES];
                    }
                } else {
                    // Источник не выбран, пытаемся определить источник по-умолчанию, с выбранной валютой
                    [self guessDefaultTargetFor:p_source initIfFalse:NO];
                }
            }
            [self checkTermsAndEnableSaveWithSource:p_source];
        }
    } else if([unwindSegue.identifier isEqualToString:@"unwindFromTargetEntitySelectToOperationEdit"]) {
        if(vc.viewModel.target) {
            p_target = vc.viewModel.target;
            [self updateUIWithTarget:p_target operation:self.viewModel.operation];
            
            if([self.viewModel checkPiredForSameCurrency]) {
                if(p_source
                   && [[p_source class] conformsToProtocol:@protocol(YYGSumAndCurrencyIdentifiable)]) {
                    id<YYGSumAndCurrencyIdentifiable> objectWithCurrency = (id<YYGSumAndCurrencyIdentifiable>)p_source;
                    if(objectWithCurrency.currencyId != p_targetCurrency.rowId) {
                        [self guessDefaultSourceFor:p_target initIfFails:YES];
                    }
                } else {
                    [self guessDefaultSourceFor:p_target initIfFails:NO];
                }
            }
            [self checkTermsAndEnableSaveWithTarget:p_target];
        }
    } else {
        @throw [NSException exceptionWithName:@"YYGOperationEditController unwindFromEntitySelectToOperationEdit fails." reason:@"Unknown unwind segue name." userInfo:nil];
    }
}

- (void)guessDefaultTargetFor:(id<YYGRowIdAndNameIdentifiable>)source initIfFalse:(BOOL)initIfFails {
    
    id<YYGRowIdAndNameIdentifiable> defaultTarget = [self.viewModel defaultTargetWithCurrency:p_sourceCurrency];
    if(defaultTarget) {
        p_target = defaultTarget;
        id<YYGSumAndCurrencyIdentifiable> objectWithCurrency = (id<YYGSumAndCurrencyIdentifiable>)p_target;
        p_targetCurrency = [self.viewModel currencyOf:objectWithCurrency];
        [self updateUIWithTarget:p_target operation:self.viewModel.operation];
        [self setDefaultFontForControls];
    }
    else if(initIfFails) {
        p_target = nil;
        p_targetCurrency = nil;
        [self updateUIWithUnknownTarget];
        [self setDefaultFontForControls];
    }
}

- (void)guessDefaultSourceFor:(id<YYGRowIdAndNameIdentifiable>)target initIfFails:(BOOL)initIfFails {
    
    id<YYGRowIdAndNameIdentifiable> defaultSource = [self.viewModel defaultSourceWithCurrency:p_targetCurrency];
    if(defaultSource) {
        p_source = defaultSource;
        id<YYGSumAndCurrencyIdentifiable> objectWithCurrency = (id<YYGSumAndCurrencyIdentifiable>)p_source;
        p_sourceCurrency = [self.viewModel currencyOf:objectWithCurrency];
        [self updateUIWithSource:p_source operation:self.viewModel.operation];
        [self setDefaultFontForControls];
    }
    else if (initIfFails) {
        p_source = nil;
        p_sourceCurrency = nil;
        [self updateUIWithUnknownSource];
        [self setDefaultFontForControls];
    }
}

#pragma mark - UITextFieldDelegate & UITextViewDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if([textField isEqual:self.textFieldSourceSum] || [textField isEqual:self.textFieldTargetSum])
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

# pragma mark - Check terms for save enable

- (BOOL)isEditControlsChanged {
    if(p_isDayChanged || p_isSourceChanged || p_isSourceSumChanged || p_isTargetChanged || p_isTargetSumChanged || p_isCommentChanged)
        return YES;
    else
        return NO;
}

- (BOOL)isDataReadyForSave {
    if(!p_day
       || ([self.viewModel isSourceNeedForSave] && !p_source)
       || ([self.viewModel isSourceSumNotNullNeedForSave] && p_sourceSum == 0.0f)
       || ([self.viewModel isTargetNeedForSave] && !p_target)
       || ([self.viewModel isTargetSumNotNullNeedForSave] && p_targetSum == 0.0f))
        return NO;
    else
        return YES;
}

#pragma mark - Change save button enable

- (void) checkTermsAndEnableSave {
    
    if([self isEditControlsChanged] && [self isDataReadyForSave]) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        if(!self.viewModel.operation) {
            self.buttonSaveAndAdd.enabled = YES;
            self.buttonSaveAndAdd.titleLabel.textColor = [UIColor whiteColor];
            self.buttonSaveAndAdd.backgroundColor = [YGTools colorForActionSaveAndAddNew];
        }
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        if(!self.viewModel.operation) {
            self.buttonSaveAndAdd.enabled = NO;
            self.buttonSaveAndAdd.titleLabel.textColor = [UIColor whiteColor];
            self.buttonSaveAndAdd.backgroundColor = [YGTools colorForActionDisable];
        }
    }
}

- (IBAction)textFieldEditingChanged:(UITextField *)sender {
    
    if([sender isEqual:self.textFieldSourceSum]) {
        p_sourceSum = [YGTools doubleFromStringCurrency:sender.text];
        if(p_sourceSum == p_sourceSumInitValue)
            p_isSourceSumChanged = NO;
        else
            p_isSourceSumChanged = YES;
        
        if(p_sourceSum == 0.0f)
            self.labelSourceSumHeader.attributedText = [YGTools attributedStringWithText:[NSString stringWithFormat:@"%@", NSLocalizedString(@"SUM", "Sum.")] color:[YGTools colorRed]];
        else
            self.labelSourceSumHeader.attributedText = [YGTools attributedStringWithText:[NSString stringWithFormat:@"%@", NSLocalizedString(@"SUM", "Sum.")] color:[UIColor blackColor]];
        
    }
    else if([sender isEqual:self.textFieldTargetSum]) {
        p_targetSum = [YGTools doubleFromStringCurrency:sender.text];
        if(p_targetSum == p_targetSumInitValue)
            p_isTargetSumChanged = NO;
        else
            p_isTargetSumChanged = YES;
        
        if(p_targetSum == 0.0f)
            self.labelTargetSumHeader.attributedText = [YGTools attributedStringWithText:[NSString stringWithFormat:@"%@", NSLocalizedString(@"SUM", "Sum.")] color:[YGTools colorRed]];
        else
            self.labelTargetSumHeader.attributedText = [YGTools attributedStringWithText:[NSString stringWithFormat:@"%@", NSLocalizedString(@"SUM", "Sum.")] color:[UIColor blackColor]];
    }
    [self checkTermsAndEnableSave];
}

- (void)textViewDidChange:(UITextView *)textView {
    if([textView isEqual:self.textViewComment]) {
        p_comment = textView.text;
        if([p_comment isEqualToString:p_commentInitValue])
            p_isCommentChanged = NO;
        else
            p_isCommentChanged = YES;
        [self checkTermsAndEnableSave];
    }
}

# pragma Save operation

- (void)saveOperation {
    
    NSDate *now = [NSDate date];
    NSString *comment = [p_comment stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if(!self.viewModel.operation) {
        
        if([self.viewModel sameSourceAndTarget])
            p_sourceSum = ((id<YYGSumAndCurrencyIdentifiable>)p_target).sum;
        else
            if([self.viewModel sameSourceAndTargetSum])
                p_sourceSum = p_targetSum;
        
        YGOperation *operation = [[YGOperation alloc]
                                  initWithType:self.viewModel.type
                                  sourceId:[self.viewModel sameSourceAndTarget] ? p_target.rowId : p_source.rowId
                                  targetId:p_target.rowId
                                  sourceSum:p_sourceSum
                                  sourceCurrencyId:[self.viewModel sameSourceAndTargetSum] ? p_targetCurrency.rowId : p_sourceCurrency.rowId
                                  targetSum:p_targetSum
                                  targetCurrencyId:p_targetCurrency.rowId
                                  day:[p_day copy]
                                  created:[now copy]
                                  modified:[now copy]
                                  comment:p_comment];
        
        NSInteger operationId = [self.viewModel addOperation:operation];
        operation.rowId = operationId;
        
        [self.viewModel recalcBalanceWith:operation];
    } else {
        
        YGOperation *oldOperation = [self.viewModel.operation copy];
        
        if(p_isDayChanged)
            self.viewModel.operation.day = [p_day copy];
        if(p_isSourceChanged) {
            self.viewModel.operation.sourceId = p_source.rowId;
            self.viewModel.operation.sourceCurrencyId = p_sourceCurrency.rowId;
        }
        if(p_isSourceSumChanged)
            self.viewModel.operation.sourceSum = p_sourceSum;
        if(p_isTargetChanged) {
            self.viewModel.operation.targetId = p_target.rowId;
            self.viewModel.operation.targetCurrencyId = p_targetCurrency.rowId;
        }
        if(p_isTargetSumChanged) {
            self.viewModel.operation.targetSum = p_targetSum;
            if([self.viewModel sameSourceAndTargetSum])
                self.viewModel.operation.sourceSum = p_targetSum;
        }
        if(p_isCommentChanged)
            self.viewModel.operation.comment = comment;
        
        self.viewModel.operation.modified = now;
        
        //[self.viewModel updateOperation:oldOperation withNew:[self.viewModel.operation copy]];
        [self.viewModel updateOperation:oldOperation withNew:self.viewModel.operation];
        
        [self.viewModel recalcBalanceWith:self.viewModel.operation];
    }
    
    // TODO: Что это?
    //        // need to recalc?
    //        if(_isDateChanged || _isAccountChanged || _isSumChanged) {
    //            [_em recalcSumOfAccount:[_account copy] forOperation:nil];
    //            // recalc of old account
    //            if(_isAccountChanged)
    //                [_em recalcSumOfAccount:[_initAccountValue copy] forOperation:nil];
    //        }
}


# pragma mark - Actions

- (void) saveButtonPressed {
    [self saveOperation];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)buttonDeletePressed:(UIButton *)sender {
    YGOperation *oldOperation = [self.viewModel.operation copy];
    [self.viewModel removeOperation:self.viewModel.operation];
    
    // TODO: пересчет баланса на несуществующую операцию! Это норм?
    [self.viewModel recalcBalanceWith:oldOperation];
    
    // TODO: Что это?
//    [_om removeOperation:self.expense];
//    [_em recalcSumOfAccount:_account forOperation:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initUIForNewOperation {
    
    // init state for monitor user changes
    p_isDayChanged = NO;
    p_isSourceChanged = NO;
    p_isSourceSumChanged = NO;
    p_isTargetChanged = NO;
    p_isTargetSumChanged = NO;
    p_isCommentChanged = NO;

    // init
    p_dayInitValue = [p_day copy];
    p_sourceInitValue = [p_source copyWithZone:nil];
    p_sourceSumInitValue = 0.0f;
    p_targetInitValue = [p_target copyWithZone:nil];
    p_targetSumInitValue = 0.0f;
    p_commentInitValue = nil;
    
    // deactivate "Add" and "Save & add new" bottons
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.buttonSaveAndAdd.enabled = NO;
    self.buttonSaveAndAdd.backgroundColor = [YGTools colorForActionDisable];
    
    self.textFieldSourceSum.text = nil;
    self.textFieldTargetSum.text = nil;
    
    if([self.viewModel showSourceSum]) {
        self.labelSourceSumHeader.textColor = [YGTools colorRed];
        [self.textFieldSourceSum becomeFirstResponder];
    }
    else if([self.viewModel showTargetSum]) {
        self.labelTargetSumHeader.textColor = [YGTools colorRed];
        [self.textFieldTargetSum becomeFirstResponder];
    }
}

- (IBAction)buttonSaveAndAddPressed:(UIButton *)sender {
    [self saveOperation];
    [self initUIForNewOperation];
}

@end
