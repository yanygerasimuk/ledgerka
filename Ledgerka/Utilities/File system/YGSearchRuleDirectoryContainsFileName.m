//
//  YGSearchRuleDirectoryContainsFileName.m
//  YGFileSystem
//
//  Created by Ян on 02/05/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGSearchRuleDirectoryContainsFileName.h"

@interface YGSearchRuleDirectoryContainsFileName (){
    NSString *_fileName;
}

@end

@implementation YGSearchRuleDirectoryContainsFileName

- (instancetype)initWithSearchedFileName:(NSString *)fileName{
    self = [super initWithType:YGSearchRuleTypeDirect];
    if(self){
        _fileName = fileName;
        self.name = @"Rule for directory to contain other file";
    }
    return self;
}

- (NSString *) descriptionRule{
    return @"Rule for directory to contain other file";
}

- (BOOL) isConfirm:(YGFileSystemObject *)object{
#ifdef FUNC_DEBUG
#undef FUNC_DEBUG
#endif
    
    if(object.type != YGFileSystemObjectTypeDirectory)
        return NO;
    else{
        
        YGDirectory *directory = [[YGDirectory alloc] initWithFileSystemObject:object];
        
        /*
        YGFile *file = [[YGFile alloc] initWithName:_fileName atPath:directory.pathFull];
         */
        
        // new path for checking existance
        NSString *checkPath = [NSString stringWithFormat:@"%@/%@", directory.pathFull, _fileName];
        NSFileManager *fm = [NSFileManager defaultManager];
        
        if(![fm fileExistsAtPath:checkPath]){
#ifdef FUNC_DEBUG
            printf("\nFile system object is not exists.");
#endif
            return NO;
        }
        else
            return YES;
    }
}

@end
