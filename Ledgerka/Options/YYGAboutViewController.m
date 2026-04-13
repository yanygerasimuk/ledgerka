//
//  YYGAboutViewController.m
//  Ledger
//
//  Created by Ян on 23/07/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YYGAboutViewController.h"
#import "YGTools.h"
#import "YYGLedgerDefine.h"
#import "YYGAppVersion.h"

@interface YYGAboutViewController()

@property (weak, nonatomic) IBOutlet UILabel *labelApplicationName;
@property (weak, nonatomic) IBOutlet UILabel *labelApplicationVersion;
@property (weak, nonatomic) IBOutlet UILabel *labelApplicationDateBuild;
@property (weak, nonatomic) IBOutlet UILabel *labelCopyright;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labelsCommon;
@end

@implementation YYGAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = NSLocalizedString(@"ABOUT_FORM_TITLE", @"Title of About form");
    
    self.labelApplicationName.text = NSLocalizedString(@"APPLICATION_NAME", @"Name of application (Ledger)");
    
    YYGAppVersion *appVersion = [[YYGAppVersion alloc] init];
    self.labelApplicationVersion.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"APPLICATION_VERSION", @"Version of application"), [appVersion toString]];

    self.labelCopyright.text = [NSString stringWithFormat:@"© %@", NSLocalizedString(@"APPLICATION_AUTHOR", @"Author of application (Yan Gerasimuk)")];
    
    // date build
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:kAppBuildDateFormat];
    NSDate *buildDate = [formatter dateFromString:kAppBuildDate];
    
    NSString *releasedString = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"APPLICATION_RELEASED_PRETEXT", @"Pretext for release build date."), [YGTools stringHumanViewDMYOfDate:buildDate]];
    
    self.labelApplicationDateBuild.text = releasedString;
    
    // name
    NSDictionary *attributesName = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:[YGTools defaultFontSize]+6]
                                     };
    NSAttributedString *attributedName = [[NSAttributedString alloc] initWithString:self.labelApplicationName.text attributes:attributesName];
    
    self.labelApplicationName.attributedText = attributedName;
    
    // other labels
    for(UILabel *label in self.labelsCommon) {
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:[YGTools defaultFontSize]]
                                     };
        
        NSAttributedString *attributed = [[NSAttributedString alloc] initWithString:label.text attributes:attributes];
        
        label.attributedText = attributed;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
