//
//  YYGTableItemModelable.h
//  Ledger
//
//  Created by Yan Gerasimuk on 30.06.2025.
//  Copyright © 2025 Yan Gerasimuk. All rights reserved.
//

typedef NS_ENUM(NSInteger, YYGTableItemLocation)
{
    YYGTableItemLocationOnce    = 0,
    YYGTableItemLocationFirst   = 1,
    YYGTableItemLocationMedium  = 2,
    YYGTableItemLocationLast    = 3
};


@protocol YYGTableItemLocationable <NSObject>

@property (nonatomic, assign) YYGTableItemLocation location;

@end


@protocol YYGTableItemRegistrable <NSObject>

@property (nonatomic, nonnull, readonly, strong) NSString *identifier;
@property (nonatomic, nonnull, readonly) Class cellClass;

@end


@protocol YYGTableItemActionable <NSObject>

@property (nonatomic, nullable, copy) void (^action)(void);

@end


@protocol YYGTableItemSelectable <NSObject>

@property (nonatomic, assign) BOOL canSelected;

@end

@protocol YYGTableItemUpdatable

- (void)updateWithViewModel:(id _Nonnull) viewModel;

@end


//@protocol YYGTableItemModelable <YYGTableItemRegistrable, YYGTableItemActionable, YYGTableItemSelectable>
//@end
