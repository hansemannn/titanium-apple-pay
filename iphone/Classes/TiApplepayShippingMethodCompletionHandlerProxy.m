/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2015 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiApplepayShippingMethodCompletionHandlerProxy.h"
#import "TiApplepaySummaryItemProxy.h"
#import "TiUtils.h"

@implementation TiApplepayShippingMethodCompletionHandlerProxy

-(void)dealloc
{
    RELEASE_TO_NIL(_handler);
    [super dealloc];
}

-(void)complete:(id _Nonnull)args
{
    if (_handler != nil) {
        ENSURE_TYPE(args, NSArray);
        id status = [args objectAtIndex:0];
        id summarayItems = [args objectAtIndex:1];
        
        ENSURE_TYPE(status, NSNumber);
        ENSURE_TYPE(summarayItems, NSArray);
        
        NSMutableArray *result = [NSMutableArray array];
        
        for (id item in summarayItems) {
            ENSURE_TYPE(item, TiApplepaySummaryItemProxy);
            [result addObject:[(TiApplepaySummaryItemProxy*)item item]];
        }
        
        _handler([TiUtils intValue:status def:PKPaymentAuthorizationStatusSuccess], result);
    }
}

@end
