#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface YYGSQLite : NSObject

+ (YYGSQLite *)shared;

- (void)execAsyncSql:(NSString *)sqlQuery
      successHandler:(void (^) (void))successHandler
      failureHandler:(void (^) (void))failureHandler;

- (void)insertAsyncSql:(NSString *)sql
                fields:(NSArray *)fields
        successHandler:(void (^) (NSInteger))successHandler
        failureHandler:(void (^) (void))failureHandler;

@end

NS_ASSUME_NONNULL_END
