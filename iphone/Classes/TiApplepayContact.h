/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2015 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import <PassKit/PassKit.h>

#ifdef USE_TI_CONTACTS
#import "TiContactsPerson.h"
#endif

@interface TiApplepayContact : PKContact {
    @private
#ifdef USE_TI_CONTACTS
    TiContactsPerson *person;
#endif
    NSDictionary *dictionary;
}

#ifdef USE_TI_CONTACTS
-(id)TiApplePay_initWithPerson:(TiContactsPerson*)_person;
#endif

-(id)initWithDictionary:(NSDictionary*)_dictionary;

@end
