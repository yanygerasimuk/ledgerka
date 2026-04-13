//
//  YGEntityManager.h
//  Ledger
//
//  Created by Ян on 11/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YGEntity.h"

@class YGOperation;

@interface YGEntityManager : NSObject

@property (strong, nonatomic, readonly) NSMutableDictionary <NSString *, NSMutableArray <YGEntity *>*> *entities;

+ (instancetype)sharedInstance;

- (instancetype)init;

- (void)addEntity:(YGEntity *)entity;
- (YGEntity *)entityById:(NSInteger)entityId type:(YGEntityType)type;
- (void)updateEntity:(YGEntity *)entity;
- (void)deactivateEntity:(YGEntity *)entity;
- (void)activateEntity:(YGEntity *)entity;
- (void)removeEntity:(YGEntity *)entity;

- (NSArray <YGEntity *> *)entitiesByType:(YGEntityType)type onlyActive:(BOOL)onlyActive exceptEntity:(YGEntity *)exceptEntity exactCounterpartyType:(YYGCounterpartyType)counterpartyType;
- (NSArray <YGEntity *> *)entitiesByType:(YGEntityType)type onlyActive:(BOOL)onlyActive exactCounterpartyType:(YYGCounterpartyType)couterpartyType;
- (NSArray <YGEntity *> *)entitiesByType:(YGEntityType)type onlyActive:(BOOL)onlyActive exceptEntity:(YGEntity *)exceptEntity;
- (NSArray <YGEntity *> *)entitiesByType:(YGEntityType)type onlyActive:(BOOL)onlyActive;
- (NSArray <YGEntity *> *)entitiesByType:(YGEntityType)type;

- (YGEntity *)entityAttachedForType:(YGEntityType)type currencyId:(NSInteger)currencyId counterpartyType:(YYGCounterpartyType)counterpartyType;
- (YGEntity *)entityAttachedForType:(YGEntityType)type counterpartyType:(YYGCounterpartyType)counterpartyType;
- (YGEntity *)entityAttachedForType:(YGEntityType)type;

- (YGEntity *)entityOnTopForType:(YGEntityType)type currencyId:(NSInteger)currencyId counterpartyType:(YYGCounterpartyType)counterpartyType;
- (YGEntity *)entityOnTopForType:(YGEntityType)type counterpartyType:(YYGCounterpartyType)counterpartyType;
- (YGEntity *)entityOnTopForType:(YGEntityType)type;
- (void)setOnlyOneDefaultEntity:(YGEntity *)entity;

- (void)recalcSumOfAccount:(YGEntity *)entity forOperation:(YGOperation *)operation;
- (void)recalcSumOfDebt:(YGEntity *)debt forOperation:(YGOperation *)operation;
- (BOOL)isExistLinkedOperationsForEntity:(YGEntity *)entity;
- (BOOL)isExistActiveEntityOfType:(YGEntityType)type;
- (BOOL)isExistDuplicateOfEntity:(YGEntity *)entity;

- (NSInteger)countOfActiveEntitiesOfType:(YGEntityType)type currencyId:(NSInteger)currencyId counterpartyType:(YYGCounterpartyType)counterpartyType;
- (NSInteger)countOfActiveEntitiesOfType:(YGEntityType)type counterpartyType:(YYGCounterpartyType)counterpartyType;
- (NSInteger)countOfActiveEntitiesOfType:(YGEntityType)type;
@end
