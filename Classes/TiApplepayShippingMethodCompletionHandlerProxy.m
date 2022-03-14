/**
 * Titanium Apple Pay
 * Copyright (c) 2015-Present by Hans Knoechel. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiApplepayShippingMethodCompletionHandlerProxy.h"
#import "TiApplepaySummaryItemProxy.h"

@implementation TiApplepayShippingMethodCompletionHandlerProxy

- (void)complete:(id _Nonnull)args
{
  if (_handler != nil) {
    ENSURE_TYPE(args, NSArray);
    id status = [args objectAtIndex:0];
    id summaryItems = [args objectAtIndex:1];

    ENSURE_TYPE(status, NSNumber);
    ENSURE_TYPE(summaryItems, NSArray);

    NSMutableArray *result = [NSMutableArray array];

    for (id item in summaryItems) {
      ENSURE_TYPE(item, TiApplepaySummaryItemProxy);
      [result addObject:[(TiApplepaySummaryItemProxy *)item item]];
    }

    _handler([TiUtils intValue:status def:PKPaymentAuthorizationStatusSuccess], result);
  }
}

@end
