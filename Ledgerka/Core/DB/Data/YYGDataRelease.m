//
//  YYGDataRelease.m
//  Ledger
//
//  Created by Ян on 22/07/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YYGDataRelease.h"
#import "YGSQLite.h"
#import "YGTools.h"

void addReleaseAccounts(void) {
    
    YGSQLite *sqlite = [YGSQLite sharedInstance];
        
    NSArray *entities = nil;
    
    NSString *now = [YGTools stringFromLocalDate:[NSDate date]];
    
    if([[YGTools languageCodeApplication] isEqualToString:@"ru"]){
        entities = @[
                     @[
                         @1, // account
                         @"Кошелёк",
                         @0.0,
                         @1, // rub
                         @1, // active
                         now,
                         now,
                         @1, // attach
                         @100,
                         [NSNull null],
                         @"8247354D-8873-4FF6-A794-DD1F276582BE"
                         ],
                     @[
                         @1, // account
                         @"Карта",
                         @0.0,
                         @1, // rub
                         @1, // active
                         now,
                         now,
                         @0, // attach
                         @101,
                         [NSNull null],
                         @"557FF784-A0E0-4419-B7B4-034FEB205B35"
                         ],
                     @[
                         @1, // account
                         @"Заначка",
                         @0.0,
                         @1, // rub
                         @1, // active
                         now,
                         now,
                         @0, // attach
                         @103,
                         [NSNull null],
                         @"03D63DFF-D1B4-4160-BA48-EF9BFE9D929D"
                         ]
                     ];
    }
    else{
        entities = @[
                     @[
                         @1, // account
                         @"Pocket",
                         @0.0,
                         @1, // rub
                         @1, // active
                         now,
                         now,
                         @1, // attach
                         @100,
                         [NSNull null],
                         @"8A3FE5DB-B49F-4C68-9746-E37E8278CFFF"
                         ],
                     @[
                         @1, // account
                         @"Card",
                         @0.0,
                         @1, // rub
                         @1, // active
                         now,
                         now,
                         @0, // attach
                         @101,
                         [NSNull null],
                         @"4EE3445B-73EB-4ED2-9C4A-48A0E0DD5E17"
                         ],
                     @[
                         @1, // account
                         @"Stash",
                         @0.0,
                         @1, // rub
                         @1, // active
                         now,
                         now,
                         @0, // attach
                         @103,
                         [NSNull null],
                         @"A6BEB1E9-B820-407D-A2A3-7A1886F37C50"
                         ]
                     ];
    }
    
    NSString *insertSQL = @"INSERT INTO entity (entity_type_id, name, sum, currency_id, active, created, modified, attach, sort, comment, uuid) "
    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
    
    [sqlite fillTable:@"entity" items:entities updateSQL:insertSQL];
}


void addReleaseExpenseCategories(){
    
    NSArray *categories = nil;
    
    NSString *now = [YGTools stringFromLocalDate:[NSDate date]];
    
    if([[YGTools languageCodeApplication] isEqualToString:@"ru"]){
        
        categories = @[
                       @[
                           @2,
                           @"Продукты",
                           @1,
                           now,
                           now,
                           @100,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"6E20F9A8-3C41-48C3-ACDB-3EE9D13458C3"
                           ],
                       @[
                           @2,
                           @"Чревоугодия",
                           @1,
                           now,
                           now,
                           @100,
                           [NSNull null],
                           @0,
                           @11,
                           @"Алкоголь, курение и т.д.",
                           @"26DF89FC-5B96-4154-A77F-CA75E46C0A89"
                           ],
                       @[
                           @2,
                           @"Хозяйство",
                           @1,
                           now,
                           now,
                           @101,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"B4DD2F31-0765-4FFE-AB4E-A8E4F8DBD39C"
                           ],
                       @[
                           @2,
                           @"Коммуналка",
                           @1,
                           now,
                           now,
                           @100,
                           [NSNull null],
                           @0,
                           @13,
                           [NSNull null],
                           @"3C19CEB2-0F6A-4FF6-8090-C3B9F2613374"
                           ],
                       @[
                           @2,
                           @"Ремонт/Мебель",
                           @1,
                           now,
                           now,
                           @102,
                           [NSNull null],
                           @0,
                           @13,
                           [NSNull null],
                           @"972AFDA7-2493-4150-A8E7-7C7BA32CDFA6"
                           ],
                       @[
                           @2,
                           @"Одежда",
                           @1,
                           now,
                           now,
                           @102,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"0A23251C-02E8-4E19-AC85-B81E43E693A6"
                           ],
                       @[
                           @2,
                           @"Здоровье",
                           @1,
                           now,
                           now,
                           @103,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"8B71940F-6A77-4A2F-B15E-035FF0C8B331"
                           ],
                       @[
                           @2, // category_type_id
                           @"Красота", // name
                           @1, // active
                           now,
                           now,
                           @101, // sort
                           [NSNull null],  // symbol
                           @0, // attach
                           @17, // parent_id
                           [NSNull null], // comment
                           @"CC3D4DF2-9397-4BC7-BB04-80FE9930ACFD"
                           ],
                       @[
                           @2,
                           @"Транспорт",
                           @1,
                           now,
                           now,
                           @104,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"AFC8E023-1DA4-4D1D-825A-AC67D97A91AD"
                           ],
                       @[
                           @2,
                           @"Связь",
                           @1,
                           now,
                           now,
                           @105,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"317D00AD-69D9-4895-88DF-CE3AF45CD598"
                           ],
                       @[
                           @2,
                           @"Образование",
                           @1,
                           now,
                           now,
                           @106,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"5CAC23ED-50D8-49FB-BE41-511FCB73C845"
                           ],
                       @[
                           @2,
                           @"Развлечения",
                           @1,
                           now,
                           now,
                           @107,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"40460653-655E-4A11-B953-50E9E072D8C7"
                           ],
                       @[
                           @2,
                           @"Домашние животные",
                           @1,
                           now,
                           now,
                           @100,
                           [NSNull null],
                           @0,
                           @22,
                           [NSNull null],
                           @"E161D8DD-1205-4DD6-A5F8-70953550E387"
                           ],
                       @[
                           @2,
                           @"Спорт",
                           @1,
                           now,
                           now,
                           @101,
                           [NSNull null],
                           @0,
                           @22,
                           [NSNull null],
                           @"71C989DF-CBAE-4585-9C49-1A39EE019B5D"
                           ],
                       @[
                           @2,
                           @"Рукоделия",
                           @1,
                           now,
                           now,
                           @101,
                           [NSNull null],
                           @0,
                           @22,
                           [NSNull null],
                           @"2D2DD8A2-A372-46FB-B8A1-7C8547FFF152"
                           ],
                       @[
                           @2,
                           @"Отдых/путешествия",
                           @1,
                           now,
                           now,
                           @104,
                           [NSNull null],
                           @0,
                           @22,
                           [NSNull null],
                           @"813376D7-3075-4F85-9FED-320CDCFD9009"
                           ],
                       @[
                           @2,
                           @"Книги",
                           @1,
                           now,
                           now,
                           @102,
                           [NSNull null],
                           @0,
                           @22,
                           [NSNull null],
                           @"2772CB2D-F6AC-4D56-8C06-375AEE92336F"
                           ],
                       @[
                           @2,
                           @"Кино/музыка",
                           @1,
                           now,
                           now,
                           @103,
                           [NSNull null],
                           @0,
                           @22,
                           [NSNull null],
                           @"F16DFB98-BE6B-472B-9960-7768422394CF"
                           ],
                       @[
                           @2,
                           @"Фото",
                           @1,
                           now,
                           now,
                           @105,
                           [NSNull null],
                           @0,
                           @22,
                           [NSNull null],
                           @"F16DFB98-BE6B-472B-9960-7768422394CF"
                           ],
                       @[
                           @2,
                           @"Семья",
                           @1,
                           now,
                           now,
                           @108,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"4CCD6A9B-AA02-4AE7-95D5-E46DE4910E7E"
                           ],
                       @[
                           @2,
                           @"Деловое",
                           @1,
                           now,
                           now,
                           @109,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"3ADE1818-2915-4124-9409-43AF717B721C"
                           ],
                       @[
                           @2,
                           @"Компьютерное",
                           @1,
                           now,
                           now,
                           @100,
                           [NSNull null],
                           @0,
                           @31,
                           [NSNull null],
                           @"D205D666-6CC8-4A68-8CBD-FC2DD7CB1E5A"
                           ],
                       @[
                           @2,
                           @"Канцелярия",
                           @1,
                           now,
                           now,
                           @101,
                           [NSNull null],
                           @0,
                           @31,
                           [NSNull null],
                           @"316A6FC5-B8E5-4641-B048-39DA5C3F5D3F"
                           ],
                       @[
                           @2,
                           @"Банковские расходы",
                           @1,
                           now,
                           now,
                           @102,
                           [NSNull null],
                           @0,
                           @31,
                           [NSNull null],
                           @"C8CCB85E-090E-47BF-927A-DE89512E9BB2"
                           ],
                       @[
                           @2,
                           @"Государство",
                           @1,
                           now,
                           now,
                           @110,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"B3411304-D92E-4D76-9E47-81B5AF350846"
                           ],
                       @[
                           @2,
                           @"Налоги",
                           @1,
                           now,
                           now,
                           @100,
                           [NSNull null],
                           @0,
                           @35,
                           [NSNull null],
                           @"58D95555-3775-41C4-BD14-6008DF89B2A7"
                           ],
                       @[
                           @2,
                           @"Штрафы",
                           @1,
                           now,
                           now,
                           @101,
                           [NSNull null],
                           @0,
                           @35,
                           [NSNull null],
                           @"58D95555-3775-41C4-BD14-6008DF89B2A7"
                           ],
                       @[
                           @2,
                           @"Потери",
                           @1,
                           now,
                           now,
                           @111,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"99CE2F1C-40C8-480D-9B56-2037E2858A98"
                           ],
                       ];
    }
    else{
        categories = @[
                       @[
                           @2,
                           @"Foodstuffs",
                           @1,
                           now,
                           now,
                           @100,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"785365BA-5849-40BD-9697-D8F223AC5B8E"
                           ],
                       @[
                           @2,
                           @"Gluttony",
                           @1,
                           now,
                           now,
                           @100,
                           [NSNull null],
                           @0,
                           @11,
                           @"Alcohol, smoking...",
                           @"2F889F1C-1BED-4762-BC70-77A8B90C740A"
                           ],
                       @[
                           @2,
                           @"Household expenses",
                           @1,
                           now,
                           now,
                           @101,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"08E47752-D091-480F-A48B-50047C9FB968"
                           ],
                       @[
                           @2,
                           @"Utility payments",
                           @1,
                           now,
                           now,
                           @100,
                           [NSNull null],
                           @0,
                           @13,
                           [NSNull null],
                           @"263D6700-A2D3-403A-B2D1-565E544C065B"
                           ],
                       @[
                           @2,
                           @"Renovation & furniture",
                           @1,
                           now,
                           now,
                           @102,
                           [NSNull null],
                           @0,
                           @13,
                           [NSNull null],
                           @"A7C10A28-69A4-4EE9-8E2B-AB01FD3E06D7"
                           ],
                       @[
                           @2,
                           @"Clothes",
                           @1,
                           now,
                           now,
                           @102,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"864A7802-673E-4604-88BF-FDD2ACA7EE5B"
                           ],
                       @[
                           @2,
                           @"Health",
                           @1,
                           now,
                           now,
                           @103,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"CAFA69CD-5860-466F-8CD0-E5DBA0ECD209"
                           ],
                       @[
                           @2, // category_type_id
                           @"Beauty", // name
                           @1, // active
                           now,
                           now,
                           @101, // sort
                           [NSNull null],  // symbol
                           @0, // attach
                           @17, // parent_id
                           [NSNull null], // comment
                           @"0D24131B-72A2-4AD2-AF41-41F914164DB4"
                           ],
                       @[
                           @2,
                           @"Transport",
                           @1,
                           now,
                           now,
                           @104,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"98A042A1-885A-4706-BC38-C74C484C72B4"
                           ],
                       @[
                           @2,
                           @"Communications",
                           @1,
                           now,
                           now,
                           @105,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"FE995121-48CF-46F5-89DE-F701C2D376F0"
                           ],
                       @[
                           @2,
                           @"Education",
                           @1,
                           now,
                           now,
                           @106,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"BFB479A0-A5CC-40B4-BC79-CEBA80920552"
                           ],
                       @[
                           @2,
                           @"Entertainment",
                           @1,
                           now,
                           now,
                           @107,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"F91525C2-C785-4BA5-884A-8D67912A1008"
                           ],
                       @[
                           @2,
                           @"Pets",
                           @1,
                           now,
                           now,
                           @100,
                           [NSNull null],
                           @0,
                           @22,
                           [NSNull null],
                           @"1811A706-6C86-4D94-84CC-2C2CF4763702"
                           ],
                       @[
                           @2,
                           @"Sport",
                           @1,
                           now,
                           now,
                           @100,
                           [NSNull null],
                           @0,
                           @22,
                           [NSNull null],
                           @"C122E9DE-75E5-4B40-9C7D-DD07078032E8"
                           ],
                       @[
                           @2,
                           @"Hand made",
                           @1,
                           now,
                           now,
                           @101,
                           [NSNull null],
                           @0,
                           @22,
                           [NSNull null],
                           @"45AEAF70-D52A-4722-8A71-FD78B694EDBD"
                           ],
                       @[
                           @2,
                           @"Rest & travel",
                           @1,
                           now,
                           now,
                           @104,
                           [NSNull null],
                           @0,
                           @22,
                           [NSNull null],
                           @"C7DC3F0D-FFAF-4B3C-954B-1D0A650349EC"
                           ],
                       @[
                           @2,
                           @"Literature",
                           @1,
                           now,
                           now,
                           @102,
                           [NSNull null],
                           @0,
                           @22,
                           [NSNull null],
                           @"70A0F513-C1BB-4029-AB58-C7042594FCBA"
                           ],
                       @[
                           @2,
                           @"Movies & music",
                           @1,
                           now,
                           now,
                           @103,
                           [NSNull null],
                           @0,
                           @22,
                           [NSNull null],
                           @"748F1C9C-2D67-4B2A-B77D-A2857FE661C2"
                           ],
                       @[
                           @2,
                           @"Photo",
                           @1,
                           now,
                           now,
                           @105,
                           [NSNull null],
                           @0,
                           @22,
                           [NSNull null],
                           @"B58C10B3-7E5C-4A83-9682-E246AB527199"
                           ],
                       @[
                           @2,
                           @"Family",
                           @1,
                           now,
                           now,
                           @108,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"0FEE6243-EBD4-4145-B990-8E8832025001"
                           ],
                       @[
                           @2,
                           @"Business",
                           @1,
                           now,
                           now,
                           @109,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"7E1EB362-AB01-4090-8E07-E9D30119F15D"
                           ],
                       @[
                           @2,
                           @"Computer expenses",
                           @1,
                           now,
                           now,
                           @100,
                           [NSNull null],
                           @0,
                           @31,
                           [NSNull null],
                           @"D10ACD47-5931-462C-8169-4F147CB46A45"
                           ],
                       @[
                           @2,
                           @"Office expenses",
                           @1,
                           now,
                           now,
                           @101,
                           [NSNull null],
                           @0,
                           @31,
                           [NSNull null],
                           @"210B629D-9658-4D55-A396-0E9E3DB72AA2"
                           ],
                       @[
                           @2,
                           @"Bank expenses",
                           @1,
                           now,
                           now,
                           @102,
                           [NSNull null],
                           @0,
                           @31,
                           [NSNull null],
                           @"6FE42832-1FF1-4A54-8265-CB0CE175AEEC"
                           ],
                       @[
                           @2,
                           @"State",
                           @1,
                           now,
                           now,
                           @110,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"3809E1A9-3055-4B8D-B722-D64E0EB9D239"
                           ],
                       @[
                           @2,
                           @"Tax",
                           @1,
                           now,
                           now,
                           @100,
                           [NSNull null],
                           @0,
                           @35,
                           [NSNull null],
                           @"F0CCFC4D-A7BB-401C-8752-BA56312D751A"
                           ],
                       @[
                           @2,
                           @"Penalty",
                           @1,
                           now,
                           now,
                           @101,
                           [NSNull null],
                           @0,
                           @35,
                           [NSNull null],
                           @"D0F40A14-7A16-4907-88D3-C10A4FF031F3"
                           ],
                       @[
                           @2,
                           @"Loss",
                           @1,
                           now,
                           now,
                           @111,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"0E3BC4CD-8FFE-442A-9C36-41E4971349A1"
                           ],
                       ];
    }
    
    NSString *insertSQL = @"INSERT INTO category (category_type_id, name, active, created, modified, sort, symbol, attach, parent_id, comment, uuid) "
    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
    
    YGSQLite *sqlite = [YGSQLite sharedInstance];
    [sqlite fillTable:@"category" items:categories updateSQL:insertSQL];
}


void addReleaseIncomeSources(){
    
    NSArray *сategories = nil;
    
    NSString *now = [YGTools stringFromLocalDate:[NSDate date]];
    
    if([[YGTools languageCodeApplication] isEqualToString:@"ru"]){
        
        сategories = @[
                       @[
                           @3,
                           @"Зарплата",
                           @1,
                           now,
                           now,
                           @100,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"B39D05F0-B8E1-43AB-8BBF-BA6B090FD137"
                           ],
                       @[
                           @3,
                           @"Разовый доход",
                           @1,
                           now,
                           now,
                           @101,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"D7FA4E2C-C4EF-4938-9BF4-EAC6D4862F25"
                           ],
                       @[
                           @3,
                           @"Подарки",
                           @1,
                           now,
                           now,
                           @102,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"E2F132F7-22DF-4308-AF0D-FBD93F49C364"
                           ],
                       @[
                           @3,
                           @"Продажа имущества",
                           @1,
                           now,
                           now,
                           @103,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"CA84582E-E0F2-4C0A-A145-5D2ED85ED942"
                           ],
                       @[
                           @3,
                           @"Возврат",
                           @1,
                           now,
                           now,
                           @104,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"CE904DA4-B9C2-434E-A82A-99D55E30B689"
                           ],
                       @[
                           @3,
                           @"Находка",
                           @1,
                           now,
                           now,
                           @105,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"B4601DF2-490E-411F-B04D-9B73F5E049BE"
                           ],
                       @[
                           @3,
                           @"Наследство",
                           @1,
                           now,
                           now,
                           @106,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"33A68374-DD9D-4160-8157-D80F2D078AC9"
                           ],
                       ];
    }
    else{
        
        сategories = @[
                       @[
                           @3,
                           @"Salary",
                           @1,
                           now,
                           now,
                           @100,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"E1E29835-7DB0-4108-8665-8718F8504BC2"
                           ],
                       @[
                           @3,
                           @"Ad hoc income",
                           @1,
                           now,
                           now,
                           @101,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"C97BC4D3-CBAA-4A4B-B7CB-61CF3FE8D23E"
                           ],
                       @[
                           @3,
                           @"Gift",
                           @1,
                           now,
                           now,
                           @102,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"508A34E5-2D8D-4858-83FE-F0B11AD22EB2"
                           ],
                       @[
                           @3,
                           @"Sale of property",
                           @1,
                           now,
                           now,
                           @103,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"D5A601B0-9704-4687-8A70-4A8827349EDA"
                           ],
                       @[
                           @3,
                           @"Return",
                           @1,
                           now,
                           now,
                           @104,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"79DB653D-DE20-4E1B-A06C-A64BFAA9D770"
                           ],
                       @[
                           @3,
                           @"Godsend",
                           @1,
                           now,
                           now,
                           @105,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"E00FA8FD-AD89-40C4-9B6F-8C775143E05A"
                           ],
                       @[
                           @3,
                           @"Inheritance",
                           @1,
                           now,
                           now,
                           @106,
                           [NSNull null],
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"6B8636A5-F587-4B8D-8EF4-F6459557E759"
                           ],
                       ];
    }
    
    NSString *insertSQL = @"INSERT INTO category (category_type_id, name, active, created, modified, sort, symbol, attach, parent_id, comment, uuid) "
    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
    
    YGSQLite *sqlite = [YGSQLite sharedInstance];
    [sqlite fillTable:@"category" items:сategories updateSQL:insertSQL];
}
