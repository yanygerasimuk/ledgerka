//
//  YYGDataCommon.m
//  Ledger
//
//  Created by Ян on 22/07/2017.
//  Copyright © 2017 Yan Gerasimuk. All rights reserved.
//

#import "YYGDataCommon.h"
#import "YGSQLite.h"
#import "YGTools.h"

void addCommonCurrencies(void) {
    
    YGSQLite *sqlite = [YGSQLite sharedInstance];
    
    NSArray *categories = nil;
    
    NSString *now = [YGTools stringFromLocalDate:[NSDate date]];
    
    if([[YGTools languageCodeApplication] isEqualToString:@"ru"]){
        categories = @[
                       @[
                           @1,
                           @"Российский рубль",
                           @1,
                           now,
                           now,
                           @100,
                           @"₽",
                           @1,
                           [NSNull null],
                           [NSNull null],
                           @"7D01B258-6D66-4384-AE7B-289D099CF9B2"
                           ],
                       @[
                           @1,
                           @"Белорусский рубль",
                           @1,
                           now,
                           now,
                           @101,
                           @"B",
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"31B4E20B-D1C7-432B-880B-3DD731114070"
                           ],
                       @[
                           @1,
                           @"Гривна",
                           @1,
                           now,
                           now,
                           @102,
                           @"₴",
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"08C97E0F-3EE0-4704-A1FF-7733EC54A50C"
                           ],
                       @[
                           @1,
                           @"Тенге",
                           @1,
                           now,
                           now,
                           @103,
                           @"₸",
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"57A6A293-FFAF-44E0-97C1-6935D10AC51E"
                           ],
                       @[
                           @1,
                           @"Доллар США",
                           @1,
                           now,
                           now,
                           @104,
                           @"$",
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"CB65D26C-4B2F-441B-92DC-CC0294AAC3DF"
                           ],
                       @[
                           @1,
                           @"Евро",
                           @1,
                           now,
                           now,
                           @105,
                           @"€",
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"216B7286-87E8-4220-B82F-D681EF01B516"
                           ],
                       @[
                           @1,
                           @"Фунт",
                           @1,
                           now,
                           now,
                           @106,
                           @"£",
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"50089B07-C4FD-4F32-BEB7-95AC24D1A0D2"
                           ],
                       @[
                           @1,
                           @"Швейцарский франк",
                           @1,
                           now,
                           now,
                           @107,
                           @"₣",
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"EC42168F-80C9-4C27-9ACD-CA5ED0C11CB6"
                           ],
                       @[
                           @1,
                           @"Юань",
                           @1,
                           now,
                           now,
                           @108,
                           @"¥",
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"C6A0BD89-0481-4764-B8B1-76757A6A6A38"
                           ],
                       @[
                           @1,
                           @"Иена",
                           @1,
                           now,
                           now,
                           @109,
                           @"¥",
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"B1391693-951D-4CAF-B8B3-09338F669E37"
                           ],
                       ];
    }
    else{
        categories = @[
                       @[
                           @1,
                           @"Russian Ruble",
                           @1,
                           now,
                           now,
                           @100,
                           @"₽",
                           @1,
                           [NSNull null],
                           [NSNull null],
                           @"302F6276-E21E-418B-B134-DABBFE0998AD"
                           ],
                       @[
                           @1,
                           @"Belarussian Ruble",
                           @1,
                           now,
                           now,
                           @101,
                           @"B",
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"169CB119-DB4F-469F-A92B-5B2B159F97EF"
                           ],
                       @[
                           @1,
                           @"Hryvnia",
                           @1,
                           now,
                           now,
                           @102,
                           @"₴",
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"C941E644-D580-4866-83F8-5C8A05F988B2"
                           ],
                       @[
                           @1,
                           @"Tenge",
                           @1,
                           now,
                           now,
                           @103,
                           @"₸",
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"C68FF7FD-0FB6-4C23-A8E3-06B359DC84E0"
                           ],
                       @[
                           @1,
                           @"US Dollar",
                           @1,
                           now,
                           now,
                           @104,
                           @"$",
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"D66B466B-DAF7-4FC5-B07C-0FBDA6FBCD5F"
                           ],
                       @[
                           @1,
                           @"Euro",
                           @1,
                           now,
                           now,
                           @105,
                           @"€",
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"D32B7A69-C92D-466A-BF61-7FD4B0BD9E72"
                           ],
                       @[
                           @1,
                           @"Pound Sterling",
                           @1,
                           now,
                           now,
                           @106,
                           @"£",
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"B7804283-C608-4CFE-AAC8-B4A9C5818D61"
                           ],
                       @[
                           @1,
                           @"Swiss Franc",
                           @1,
                           now,
                           now,
                           @107,
                           @"₣",
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"247D2AD1-8563-42D8-BEDD-4E2D9670562C"
                           ],
                       @[
                           @1,
                           @"Yuan Renminbi",
                           @1,
                           now,
                           now,
                           @108,
                           @"¥",
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"8B8D97D0-62D4-40A5-A333-ECCD2107177F"
                           ],
                       @[
                           @1,
                           @"Yen",
                           @1,
                           now,
                           now,
                           @109,
                           @"¥",
                           @0,
                           [NSNull null],
                           [NSNull null],
                           @"9CCFDB35-885C-4E75-9872-F030656A95A0"
                           ],
                       ];
    }
    
    NSString *insertSQL = @"INSERT INTO category (category_type_id, name, active, created, modified, sort, symbol, attach, parent_id, comment, uuid) "
    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
    
    [sqlite fillTable:@"category" items:categories updateSQL:insertSQL];
}
