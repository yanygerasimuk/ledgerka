//
//  YGEntityManager.m
//  Ledger
//
//  Created by Ян on 11/06/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YGEntityManager.h"
#import "YGOperationManager.h"
#import "YGSQLite.h"
#import "YGTools.h"
#import "YYGLedgerDefine.h"

@interface YGEntityManager () {
    YGSQLite *p_sqlite;
    dispatch_queue_t p_queue;
}
@end

@implementation YGEntityManager

@synthesize entities = _entities;

#pragma mark - Singleton & init

+ (instancetype)sharedInstance {
    static YGEntityManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[YGEntityManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if(self){
        p_sqlite = [YGSQLite sharedInstance];
        p_queue = dispatch_queue_create(kEntitiesQueue, NULL);

        [self buildEntitiesCache];
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(buildEntitiesCache)
                       name:@"DatabaseRestoredEvent"
                     object:nil];
    }
    return self;
}

- (void)dealloc {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}

#pragma Entities setter & getter

- (void)setEntities:(NSMutableDictionary<NSString *,NSMutableArray<YGEntity *> *> *)entities {
    __weak YGEntityManager *weakSelf = self;
    dispatch_async(p_queue, ^{
        YGEntityManager *strongSelf = weakSelf;
        if(strongSelf)
            strongSelf->_entities = entities;
    });
}

- (NSMutableDictionary<NSString *,NSMutableArray<YGEntity *> *> *)entities {
    __weak YGEntityManager *weakSelf = self;
    dispatch_sync(p_queue, ^{
        YGEntityManager *strongSelf = weakSelf;
        if(strongSelf && !strongSelf->_entities) {
            strongSelf->_entities = [[NSMutableDictionary alloc] init];
        }
    });
    return _entities;
}

#pragma mark - Inner methods for memory cache process

- (NSArray <YGEntity *> *)entitiesFromDb {
    
    NSString *sqlQuery = @"SELECT entity_id, entity_type_id, name, sum, currency_id, active, created, modified, attach, sort, comment, uuid, counterparty_id, counterparty_type_id FROM entity ORDER BY active DESC, sort ASC;";
    
    NSArray *rawList = [p_sqlite selectWithSqlQuery:sqlQuery];
    
    NSMutableArray <YGEntity *> *result = [[NSMutableArray alloc] init];
    
    for(NSArray *arr in rawList) {
        
        NSInteger rowId = [arr[0] integerValue];
        YGEntityType type = [arr[1] integerValue];
        NSString *name = [arr[2] isEqual:[NSNull null]] ? nil : arr[2];
        double sum = [arr[3] doubleValue];
        NSInteger currencyId = [arr[4] integerValue];
        BOOL active = [arr[5] boolValue];
        NSDate *created = [YGTools dateFromString:arr[6]];
        NSDate *modified = [YGTools dateFromString:arr[7]];
        BOOL attach = [arr[8] boolValue];
        NSInteger sort = [arr[9] integerValue];
        NSString *comment = [arr[10] isEqual:[NSNull null]] ? nil : arr[10];
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:arr[11]];
        NSInteger counterpartyId = [arr[12] isEqual:[NSNull null]] ? -1 : [arr[12] integerValue]; // TODO:
        NSInteger counterpartyType = [arr[13] isEqual:[NSNull null]] ? -1 : [arr[13] integerValue];
        
        YGEntity *entity = [[YGEntity alloc] initWithRowId:rowId type:type name:name sum:sum currencyId:currencyId active:active created:created modified:modified attach:attach sort:sort comment:comment uuid:uuid counterpartyId:counterpartyId counterpartyType:counterpartyType];
        
        [result addObject:entity];
    }
    return [result copy];
}

- (void)buildEntitiesCache {
    
    NSArray *entitiesRaw = [self entitiesFromDb];
    
    NSMutableDictionary <NSString *, NSMutableArray <YGEntity *> *> *entitiesResult = [[NSMutableDictionary alloc] init];
    
    NSString *typeString = nil;
    for(YGEntity *entity in entitiesRaw) {
        
        typeString = NSStringFromEntityType(entity.type);
        
        if([entitiesResult valueForKey:typeString]){
            [[entitiesResult valueForKey:typeString] addObject:entity];
        } else {
            [entitiesResult setValue:[[NSMutableArray alloc] init] forKey:typeString];
            [[entitiesResult valueForKey:typeString] addObject:entity];
        }
    }
    
    // sort entities in each inner array
    NSArray *types = [entitiesResult allKeys];
    for(NSString *type in types)
        [self sortEntitiesInArray:entitiesResult[type]];
    
    self.entities = entitiesResult;
    
    // generate event
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"EntityManagerCacheUpdateEvent"
                          object:nil];
}

/**
 @warning It will be better if in table entities we have colomn date_unix for sort.
 */
- (void)sortEntitiesInArray:(NSMutableArray <YGEntity *>*)array {
    
    NSSortDescriptor *sortOnActiveByDesc = [[NSSortDescriptor alloc] initWithKey:@"active" ascending:NO];
    NSSortDescriptor *sortOnSortByAsc = [[NSSortDescriptor alloc] initWithKey:@"sort" ascending:YES];
    NSSortDescriptor *sortOnCreatedByAsc = [[NSSortDescriptor alloc] initWithKey:@"created"  ascending:YES];
    
    [array sortUsingDescriptors:@[sortOnActiveByDesc, sortOnSortByAsc, sortOnCreatedByAsc]];
}

#pragma mark - Actions on entity(s)

- (NSInteger)idAddEntity:(YGEntity *)entity {
    
    NSInteger rowId = -1;
    
    @try {
        
        NSArray *entityArr = [NSArray arrayWithObjects:
                              [NSNumber numberWithInteger:entity.type], // entity_type_id
                              entity.name ? entity.name : [NSNull null], // name
                              [NSNumber numberWithDouble:entity.sum],
                              [NSNumber numberWithInteger:entity.currencyId], //currencyId
                              [NSNumber numberWithBool:entity.isActive], // active
                              [YGTools stringFromDate:entity.created], // active_from,
                              entity.modified ? [YGTools stringFromDate:entity.modified] : [NSNull null], // active_to,
                              [NSNumber numberWithBool:entity.isAttach], // attach,
                              [NSNumber numberWithInteger:entity.sort], // sort,
                              entity.comment ? entity.comment : [NSNull null], //comment,
                              [entity.uuid UUIDString],
                              entity.type == YGEntityTypeDebt ? [NSNumber numberWithInteger:entity.counterpartyId] : [NSNull null],
                              entity.type == YGEntityTypeDebt ? [NSNumber numberWithInteger:entity.counterpartyType] : [NSNull null],
                              nil];
        
        NSString *insertSQL = @"INSERT INTO entity (entity_type_id, name, sum, currency_id, active, created, modified, attach, sort, comment, uuid, counterparty_id, counterparty_type_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
        
        // db
        rowId = [p_sqlite addRecord:entityArr insertSQL:insertSQL];
    }
    @catch (NSException *exception) {
        NSLog(@"Fail in -[YGEntityManager idAddEntity]. Exception: %@", [exception description]);
    }
    @finally {
        return rowId;
    }
}

- (void)addEntity:(YGEntity *)entity {
    
    // add entity to db
    NSInteger rowId = [self idAddEntity:entity];
    YGEntity *newEntity = [entity copy];
    newEntity.rowId = rowId;
    
    // if entity set is default unset another ones
    if(newEntity.attach)
        [self setOnlyOneDefaultEntity:newEntity];
    
    // add entity to memory cache, init if needs
    if(![self.entities valueForKey:NSStringFromEntityType(newEntity.type)]){
        [self.entities setValue:[[NSMutableArray alloc] init] forKey:NSStringFromEntityType(newEntity.type)];
    }
    [[self.entities valueForKey:NSStringFromEntityType(newEntity.type)] addObject:newEntity];
    [self sortEntitiesInArray:[self.entities valueForKey:NSStringFromEntityType(newEntity.type)]];
    
    // generate event
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"EntityManagerCacheUpdateEvent"
                          object:nil];
}

/**
@warning May be throw exception when return array count > 1?
 */
- (YGEntity *)entityById:(NSInteger)entityId type:(YGEntityType)type {
    NSArray <YGEntity *> *entitiesByType = [self.entities valueForKey:NSStringFromEntityType(type)];
    NSPredicate *idPredicate = [NSPredicate predicateWithFormat:@"rowId = %ld", entityId];
    return [[entitiesByType filteredArrayUsingPredicate:idPredicate] firstObject];
}

/**
 Update entity in db and memory cache. Write object as is, without any modifications.
 
 @warning Is entity needs to update in inner storage?
 @warning It seems entity updated in EditController edit by reference, so...
 */
- (void)updateEntity:(YGEntity *)entity{
        
    // get memory cache
    NSMutableArray <YGEntity *> *entitiesByType = [self.entities valueForKey:NSStringFromEntityType(entity.type)];
    
    // get update entity
    YGEntity *replacedEntity = [self entityById:entity.rowId type:entity.type];
    
    NSString *updateSQL = [NSString stringWithFormat:@"UPDATE entity SET entity_type_id=%@, name=%@, sum=%@, currency_id=%@, active=%@, created=%@, modified=%@, attach=%@, sort=%@, comment=%@, counterparty_id=%@, counterparty_type_id=%@ WHERE entity_id=%@ AND uuid=%@;",
                           [YGTools sqlStringForInt:entity.type],
                           [YGTools sqlStringForStringOrNull:entity.name],
                           [YGTools sqlStringForDecimal:entity.sum],
                           [YGTools sqlStringForIntOrNull:entity.currencyId],
                           [YGTools sqlStringForBool:entity.isActive],
                           [YGTools sqlStringForDateLocalOrNull:entity.created],
                           [YGTools sqlStringForDateLocalOrNull:entity.modified],
                           [YGTools sqlStringForBool:entity.attach],
                           [YGTools sqlStringForIntOrDefault:entity.sort],
                           [YGTools sqlStringForStringOrNull:entity.comment],
                           [YGTools sqlStringForIntOrNull:entity.counterpartyId],
                           [YGTools sqlStringForIntOrNull:entity.counterpartyType],
                           [YGTools sqlStringForIntOrNull:entity.rowId],
                           [YGTools sqlStringForStringNotNull:[entity.uuid UUIDString]]
                           ];
        
    [p_sqlite execSQL:updateSQL];
    
    // if entity set as default unset another ones
    if(!replacedEntity.attach && entity.attach)
        [self setOnlyOneDefaultEntity:entity];
    
    // update memory cache
    NSUInteger index = [entitiesByType indexOfObject:replacedEntity];
    entitiesByType[index] = [entity copy];
    
    // sort memory cache
    [self sortEntitiesInArray:entitiesByType];
    
    // generate event
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"EntityManagerCacheUpdateEvent"
                          object:nil];
    
    // generate special event if entity has linked operations
    if([self isExistLinkedOperationsForEntity:entity]){
        [center postNotificationName:@"EntityManagerEntityWithOperationsUpdateEvent" object:nil];
    }
}

- (void)deactivateEntity:(YGEntity *)entity {
    
    NSDate *now = [NSDate date];
    
    // update db
    NSString *updateSQL = [NSString stringWithFormat:@"UPDATE entity SET active=0, modified=%@ WHERE entity_id=%ld;", [YGTools sqlStringForDateLocalOrNull:now], (long)entity.rowId];
    
    [p_sqlite execSQL:updateSQL];

    // update memory cache
    NSMutableArray <YGEntity *> *entitiesByType = [self.entities valueForKey:NSStringFromEntityType(entity.type)];
    YGEntity *updateEntity = [entitiesByType objectAtIndex:[entitiesByType indexOfObject:entity]];
    updateEntity.active = NO;
    updateEntity.modified = now;
    
    // sort memory cache
    [self sortEntitiesInArray:entitiesByType];
    
    // generate event
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"EntityManagerCacheUpdateEvent"
                          object:nil];
}

- (void)activateEntity:(YGEntity *)entity {
    
    NSDate *now = [NSDate date];
    
    // update db
    NSString *updateSQL = [NSString stringWithFormat:@"UPDATE entity SET active=1, modified=%@ WHERE entity_id=%ld;", [YGTools sqlStringForDateLocalOrNull:now], (long)entity.rowId];
    
    [p_sqlite execSQL:updateSQL];
    
    // update memory cache
    NSMutableArray <YGEntity *> *entitiesByType = [self.entities valueForKey:NSStringFromEntityType(entity.type)];
    YGEntity *updateEntity = [entitiesByType objectAtIndex:[entitiesByType indexOfObject:entity]];
    updateEntity.active = YES;
    updateEntity.modified = now;
    
    [self sortEntitiesInArray:entitiesByType];
    
    // generate event
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"EntityManagerCacheUpdateEvent"
                          object:nil];
}

- (void)removeEntity:(YGEntity *)entity {
    
    // update db
    NSString* deleteSQL = [NSString stringWithFormat:@"DELETE FROM entity WHERE entity_id = %ld;", (long)entity.rowId];
    
    [p_sqlite removeRecordWithSQL:deleteSQL];
    
    // update memory cache
    NSMutableArray <YGEntity *> *entitiesByType = [self.entities valueForKey:NSStringFromEntityType(entity.type)];
    [entitiesByType removeObject:entity];
    
    // generate event
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"EntityManagerCacheUpdateEvent"
                          object:nil];
}

#pragma mark - Lists of entitites

- (NSArray <YGEntity *> *)entitiesByType:(YGEntityType)type onlyActive:(BOOL)onlyActive exceptEntity:(YGEntity *)exceptEntity exactCounterpartyType:(YYGCounterpartyType)counterpartyType {
    
    NSArray <YGEntity *> *entities = [self.entities valueForKey:NSStringFromEntityType(type)];
    
    if(entities
       && [entities count] > 0
       && onlyActive) {
        NSPredicate *activePredicate = [NSPredicate predicateWithFormat:@"active = YES"];
        entities = [entities filteredArrayUsingPredicate:activePredicate];
    }
    
    if(entities
       && [entities count] > 0
       && exceptEntity) {
        NSPredicate *exceptPredicate = [NSPredicate predicateWithFormat:@"rowId != %ld", exceptEntity.rowId];
        entities = [entities filteredArrayUsingPredicate:exceptPredicate];
    }
    
    if(entities
       && [entities count] > 0
       && type == YGEntityTypeDebt
       && counterpartyType != YYGCounterpartyTypeNone) {
        NSPredicate *exactPredicate = [NSPredicate predicateWithFormat:@"counterpartyType = %ld", counterpartyType];
        entities = [entities filteredArrayUsingPredicate:exactPredicate];
    }
    
    return entities;
}

- (NSArray <YGEntity *> *)entitiesByType:(YGEntityType)type onlyActive:(BOOL)onlyActive exactCounterpartyType:(YYGCounterpartyType)couterpartyType {
    return [self entitiesByType:type onlyActive:onlyActive exceptEntity:nil exactCounterpartyType:couterpartyType];
}

- (NSArray <YGEntity *> *)entitiesByType:(YGEntityType)type onlyActive:(BOOL)onlyActive exceptEntity:(YGEntity *)exceptEntity {
    return [self entitiesByType:type onlyActive:onlyActive exceptEntity:exceptEntity exactCounterpartyType:YYGCounterpartyTypeNone];
}

- (NSArray <YGEntity *> *)entitiesByType:(YGEntityType)type onlyActive:(BOOL)onlyActive {
    return [self entitiesByType:type onlyActive:onlyActive exceptEntity:nil exactCounterpartyType:YYGCounterpartyTypeNone];
}

- (NSArray <YGEntity *> *)entitiesByType:(YGEntityType)type {
    return [self entitiesByType:type onlyActive:NO exceptEntity:nil exactCounterpartyType:YYGCounterpartyTypeNone];
}

#pragma mark - Auxiliary methods

- (YGEntity *)entityAttachedForType:(YGEntityType)type currencyId:(NSInteger)currencyId counterpartyType:(YYGCounterpartyType)counterpartyType {
#ifdef FUNC_DEBUG
#undef FUNC_DEBUG
#endif
    
#ifdef FUNC_DEBUG
    NSLog(@"YGEntityManager entityAttachedForType:%@ currencyId:%ld counterpartyType:%@", NSStringFromEntityType(type), currencyId, NSStringFromCounterpartyType(counterpartyType));
#endif
    
    NSArray <YGEntity *> *entities = [self.entities valueForKey:NSStringFromEntityType(type)];
    
#ifdef FUNC_DEBUG
    NSLog(@"entities filtered by type count: %ld", [entities count]);
#endif
    
    // Filter for active and attached
    NSPredicate *isActiveAndAttach = [NSPredicate predicateWithFormat:@"active = YES && attach = YES"];
    if(entities
       && [entities count] > 0) {
        entities = [entities filteredArrayUsingPredicate:isActiveAndAttach];
#ifdef FUNC_DEBUG
        NSLog(@"entities filtered by active and attach count: %ld", [entities count]);
#endif
    }
    
    // Filter for currency
    if(entities
       && [entities count] > 0
       && currencyId > 0) {
        NSPredicate *hasCurrency = [NSPredicate predicateWithFormat:@"currencyId = %ld", currencyId];
        entities = [entities filteredArrayUsingPredicate:hasCurrency];
#ifdef FUNC_DEBUG
        NSLog(@"entities filtered by currency count: %ld", [entities count]);
#endif
    }
    
    // Filter for counterpartyType
    if(entities
       && [entities count] > 0
       && type == YGEntityTypeDebt
       && counterpartyType != YYGCounterpartyTypeNone) {
        NSPredicate *hasCounterparty = [NSPredicate predicateWithFormat:@"counterpartyType = %ld", counterpartyType];
        entities = [entities filteredArrayUsingPredicate:hasCounterparty];
#ifdef FUNC_DEBUG
        NSLog(@"entities filtered by counterpartyType count: %ld", [entities count]);
#endif
    }
    
    if(entities && [entities count] > 0)
        return [entities firstObject];
    else
        return nil;
}

/**
 Return only one attached entity for type. Terms for entity: equals type, active, attach, and must be only one. Else return nil.
 
 */
- (YGEntity *)entityAttachedForType:(YGEntityType)type counterpartyType:(YYGCounterpartyType)counterpartyType {
    return [self entityAttachedForType:type currencyId:-1 counterpartyType:counterpartyType];
}

- (YGEntity *)entityAttachedForType:(YGEntityType)type {
    return [self entityAttachedForType:type counterpartyType:YYGCounterpartyTypeNone];
}

/**
 NSString *sqlQuery = [NSString stringWithFormat:@"SELECT entity_id, entity_type_id, name, sum, currency_id, active, active_from, active_to, attach, sort, comment  FROM entity WHERE entity_type_id = %ld AND active = %d ORDER BY sort ASC LIMIT 1;", type, YGBooleanValueYES];
 */
- (YGEntity *)entityOnTopForType:(YGEntityType)type currencyId:(NSInteger)currencyId counterpartyType:(YYGCounterpartyType)counterpartyType {
#ifndef FUNC_DEBUG
#define FUNC_DEBUG
#endif
    
#ifdef FUNC_DEBUG
    NSLog(@"entityOnTopForType:%@ currencyId:%ld counterpartyType:%@", NSStringFromEntityType(type), (long)currencyId, NSStringFromCounterpartyType(counterpartyType));
#endif
    
    NSArray <YGEntity *> *entities = [self.entities valueForKey:NSStringFromEntityType(type)];
#ifdef FUNC_DEBUG
    NSLog(@"entities with type count: %ld", (long)[entities count]);
#endif
    
    NSPredicate *isActive = [NSPredicate predicateWithFormat:@"active = YES"];
    entities = [entities filteredArrayUsingPredicate:isActive];
#ifdef FUNC_DEBUG
    NSLog(@"entities with active count: %ld", (long)[entities count]);
#endif
    
    if(entities
       && [entities count] > 0
       && currencyId > 0) {
        NSPredicate *hasCurrency = [NSPredicate predicateWithFormat:@"currencyId = %ld", currencyId];
        entities = [entities filteredArrayUsingPredicate:hasCurrency];
#ifdef FUNC_DEBUG
        NSLog(@"entities with currencyId count: %ld", (long)[entities count]);
#endif
    }
    
    if(entities
       && [entities count] > 0
       && type == YGEntityTypeDebt
       && counterpartyType != YYGCounterpartyTypeNone) {
        NSPredicate *hasCounterparty = [NSPredicate predicateWithFormat:@"counterpartyType = %ld", counterpartyType];
        entities = [entities filteredArrayUsingPredicate:hasCounterparty];
#ifdef FUNC_DEBUG
        NSLog(@"entities with debt type and counterpartyType count: %ld", (long)[entities count]);
#endif
    }
    
    if(entities && [entities count] > 0)
        return [entities firstObject];
    else
        return nil;
}

- (YGEntity *)entityOnTopForType:(YGEntityType)type counterpartyType:(YYGCounterpartyType)counterpartyType {
    return [self entityOnTopForType:type currencyId:-1 counterpartyType:counterpartyType];
}

- (YGEntity *)entityOnTopForType:(YGEntityType)type {
    return [self entityOnTopForType:type counterpartyType:YYGCounterpartyTypeNone];
}

- (void)setOnlyOneDefaultEntity:(YGEntity *)entity {
    
    NSDate *now = [NSDate date];
    
    // update db
    NSString *updateSQL = [NSString stringWithFormat:@"UPDATE entity SET attach=0, modified=%@ WHERE entity_type_id = %ld AND entity_id != %ld AND attach<>0;", [YGTools sqlStringForDateLocalOrNull:now], (long)entity.type, (long)entity.rowId];
    
    [p_sqlite execSQL:updateSQL];
    
    // update inner storage
    NSPredicate *unAttachedPredicate = [NSPredicate predicateWithFormat:@"type = %ld && rowId != %ld && attach != NO", entity.type, entity.rowId];
    
    NSArray <YGEntity *> *updateEntities = [[self.entities valueForKey:NSStringFromEntityType(entity.type)]filteredArrayUsingPredicate:unAttachedPredicate];
    
    if([updateEntities count] > 0){
        for(YGEntity *ent in updateEntities) {
            ent.attach = NO;
            ent.modified = now;
        }
    }
}

/**
 

 @param debt Debt for recalc.
 @param operation Operation may be nil, for example, during delete operation.
 */
- (void)recalcSumOfDebt:(YGEntity *)debt forOperation:(YGOperation *)operation {
    
    YGOperationManager *operationManager = [YGOperationManager sharedInstance];
    
    
    YGOperation *lastSetDebt = [operationManager lastOperationOfType:YGOperationTypeSetDebt withTargetId:debt.rowId];
    
    NSArray <YGOperation *> *operations;
    if(lastSetDebt)
        operations = [operationManager operationsWithDebtId:debt.rowId afterSetDebt:lastSetDebt];
    else
        operations = [operationManager operationsWithDebtId:debt.rowId];
    
    if([operations count] > 0) {
        
        double totalSum;
        if(lastSetDebt)
            totalSum = lastSetDebt.targetSum;
        else
            totalSum = 0.0f;
        
        for (YGOperation *oper in operations) {
            
            switch (oper.type) {
                case YGOperationTypeGiveDebt:
                    totalSum += oper.targetSum;
                    break;
                case YGOperationTypeRepaymentDebt:
                    totalSum -= oper.sourceSum;
                    break;
                case YGOperationTypeGetCredit:
                    totalSum += oper.sourceSum;
                    break;
                case YGOperationTypeReturnCredit:
                    totalSum -= oper.targetSum;
                    break;
                case YGOperationTypeSetDebt:
                    break;
                default:
                    NSLog(@"oper in default: \n%@", [oper description]);
                    
                    @throw [NSException exceptionWithName:@"YGEntityManager recalcSumOfDebt:forOperation:" reason:@"Unknown operation type." userInfo:nil];
            }
        }
        
        if(debt.sum != totalSum) {
            debt.sum = totalSum;
            debt.modified = [NSDate date];
            [self updateEntity:[debt copy]];
        } else {
            NSLog(@"Sum of debut is not changed.");
        }
    }
}

#pragma mark - Working with Operations: reculc and check of exist operations for entity
/**
 @warning Parametr forOperation: works only for new operations, for edit operations must by nil;
 
 */
- (void)recalcSumOfAccount:(YGEntity *)account forOperation:(YGOperation *)operation {
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        @try {
            // check for entity type
            if(account.type != YGEntityTypeAccount)
                @throw [NSException exceptionWithName:@"-[YGEntityManager recalcSumOfAccount:forOperation" reason:@"Recalc can not be made for this entity type" userInfo:nil];
            
            // check for operation type, if operation is AccountActual recalc does not necessary
            if(operation.type == YGOperationTypeAccountActual)
                return;
            
            YGOperationManager *om = [YGOperationManager sharedInstance];
            YGOperation *lastActualAccount = [om lastOperationOfType:YGOperationTypeAccountActual withTargetId:account.rowId];
            
            // check for more near date of actual account operation
            if(operation && lastActualAccount) {
                
                if([lastActualAccount.day compare:operation.day] == NSOrderedDescending)
                    return;
                else if([lastActualAccount.day compare:operation.day] == NSOrderedSame
                        && [lastActualAccount.modified compare:operation.modified] == NSOrderedDescending)
                    return;
            }
            
            // get source sum
            double totalSum;
            
            if(lastActualAccount)
                totalSum = lastActualAccount.targetSum;
            else
                totalSum = 0.0f;
            
            NSArray <YGOperation *>*operations = nil;
            if(lastActualAccount)
                operations = [om operationsWithAccountId:account.rowId sinceAccountActual:lastActualAccount];
            else
                operations = [om operationsWithAccountId:account.rowId];
            
            if([operations count] > 0) {
                for(YGOperation *oper in operations) {
                    switch (oper.type) {
                        case YGOperationTypeIncome:
                            totalSum += oper.targetSum;
                            break;
                        case YGOperationTypeExpense:
                            totalSum -= oper.sourceSum;
                            break;
                        case YGOperationTypeTransfer:
                            if(oper.sourceId == account.rowId)
                                totalSum -= oper.sourceSum;
                            else if (oper.targetId == account.rowId)
                                totalSum += oper.targetSum;
                            else
                                @throw [NSException exceptionWithName:@"-[YGEntityManager recalcSumOfAccount:forOperation:" reason:@"Calc behavior is not defined for this transfer" userInfo:nil];
                            break;
                        case YGOperationTypeGiveDebt:
                            totalSum -= oper.sourceSum;
                            break;
                        case YGOperationTypeRepaymentDebt:
                            totalSum += oper.targetSum;
                            break;
                        case YGOperationTypeGetCredit:
                            totalSum += oper.targetSum;
                            break;
                        case YGOperationTypeReturnCredit:
                            totalSum -= oper.sourceSum;
                            break;
                        case YGOperationTypeAccountActual:
                        case YGOperationTypeSetDebt:
                        default:
                            @throw [NSException exceptionWithName:@"-[YGEntityManager recalcSumOfAccount:forOperation:" reason:@"Calc behavior for this type of operation does not implement" userInfo:nil];
                    }
                }
            }
            
            // is account needs to update?
            if(account.sum != totalSum) {
                account.sum = totalSum;
                account.modified = [NSDate date];
                [self updateEntity:[account copy]];
            }
        }
        @catch (NSException *ex) {
            NSLog(@"Fail in -[YGEntityManager recalcSumOfAccount:forOperation:]. Exception: %@", [ex description]);
        }
    });
}

/**
 Is linked operations for entity exist. When delete entity we must check it.
 
 @entity Entity for check (account, debt, so on).
 
 @return Operation exist.
 */
- (BOOL)isExistLinkedOperationsForEntity:(YGEntity *)entity {
    
    // search in operations
    NSString *selectSql = [NSString stringWithFormat:@"SELECT operation_id FROM operation "
                           "WHERE "
                           "(operation_type_id IN (%ld,%ld,%ld,%ld,%ld) AND source_id = %ld) OR "
                           "(operation_type_id IN (%ld,%ld,%ld,%ld,%ld,%ld) AND target_id = %ld) "
                           "LIMIT 1;",
                           (long)YGOperationTypeExpense, (long)YGOperationTypeAccountActual, (long)YGOperationTypeTransfer, (long)YGOperationTypeGetCredit, (long)YGOperationTypeRepaymentDebt, (long)entity.rowId,
                           (long)YGOperationTypeIncome, (long)YGOperationTypeAccountActual, (long)YGOperationTypeTransfer, (long)YGOperationTypeReturnCredit, (long)YGOperationTypeGiveDebt, (long)YGOperationTypeSetDebt, (long)entity.rowId
                           ];
    
    NSArray *operations = [p_sqlite selectWithSqlQuery:selectSql];
    
    if([operations count] > 0)
        return YES;
    else
        return NO;
}

- (BOOL)isExistActiveEntityOfType:(YGEntityType)type {
    
    NSArray *entitiesOfType = [self entitiesByType:type];
    
    NSPredicate *activePredicate = [NSPredicate predicateWithFormat:@"active = YES"];
    
    NSArray *activeEntities = [entitiesOfType filteredArrayUsingPredicate:activePredicate];
    
    if([activeEntities count] > 0)
        return YES;
    else
        return NO;
}

- (BOOL)isExistDuplicateOfEntity:(YGEntity *)entity {
    
    NSArray *entitiesOfType = [self entitiesByType:entity.type];
    
    NSPredicate *duplicatePredicate;
    if(entity.rowId == -1) {
        duplicatePredicate = [NSPredicate predicateWithFormat:@"type = %ld AND name = %@ AND currencyId = %ld", entity.type, entity.name, entity.currencyId];
    } else {
        duplicatePredicate = [NSPredicate predicateWithFormat:@"type = %ld AND name = %@ AND currencyId = %ld AND rowId != %ld", entity.type, entity.name, entity.currencyId, entity.rowId];
    }
    
    NSArray *duplicateEntities = [entitiesOfType filteredArrayUsingPredicate:duplicatePredicate];
    
    if([duplicateEntities count] > 0)
        return YES;
    else
        return NO;
}

- (NSInteger)countOfActiveEntitiesOfType:(YGEntityType)type currencyId:(NSInteger)currencyId counterpartyType:(YYGCounterpartyType)counterpartyType {
#ifdef FUNC_DEBUG
#undef FUNC_DEBUG
#endif
    
#ifdef FUNC_DEBUG
    NSLog(@"YGEntityManager countOfActiveEntitiesOfType:%@ currencyId:%ld counterpartyType:%@", NSStringFromEntityType(type), currencyId, NSStringFromCounterpartyType(counterpartyType));
#endif
    
    NSArray *entities = [self entitiesByType:type];
    
#ifdef FUNC_DEBUG
    NSLog(@"entities with count: %ld", [entities count]);
#endif
    
    NSPredicate *isActive = [NSPredicate predicateWithFormat:@"active = YES"];
    entities = [entities filteredArrayUsingPredicate:isActive];
#ifdef FUNC_DEBUG
    NSLog(@"entities with count: %ld", [entities count]);
#endif
    
    if(entities
       && [entities count] > 0
       && currencyId > 0) {
        NSPredicate *hasCurrency = [NSPredicate predicateWithFormat:@"currencyId = %ld", currencyId];
        entities = [entities filteredArrayUsingPredicate:hasCurrency];
#ifdef FUNC_DEBUG
        NSLog(@"entities with currency count: %ld", [entities count]);
#endif
    }

    if(entities
       && [entities count] > 0
       && type == YGEntityTypeDebt
       && counterpartyType != YYGCounterpartyTypeNone) {
        NSPredicate *hasCounterparty = [NSPredicate predicateWithFormat:@"counterpartyType = %ld", counterpartyType];
        entities = [entities filteredArrayUsingPredicate:hasCounterparty];
#ifdef FUNC_DEBUG
        NSLog(@"entities with type debt and counterparty count: %ld", [entities count]);
#endif
    }
    return [entities count];
}

- (NSInteger)countOfActiveEntitiesOfType:(YGEntityType)type counterpartyType:(YYGCounterpartyType)counterpartyType {
    return [self countOfActiveEntitiesOfType:type currencyId:-1 counterpartyType:counterpartyType];
}

- (NSInteger)countOfActiveEntitiesOfType:(YGEntityType)type {
    return [self countOfActiveEntitiesOfType:type counterpartyType:YYGCounterpartyTypeNone];
}

@end
