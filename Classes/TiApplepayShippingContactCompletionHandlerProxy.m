/**
 * Titanium Apple Pay
 * Copyright (c) 2015-Present by Hans Knoechel. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiApplepayShippingContactCompletionHandlerProxy.h"
#import "TiApplepayShippingMethodProxy.h"
#import "TiApplepaySummaryItemProxy.h"
#import "TiUtils.h"

@implementation TiApplepayShippingContactCompletionHandlerProxy

- (void)complete:(id _Nonnull)args
{
  if (_handler != nil) {

    ENSURE_TYPE(args, NSArray);
    ENSURE_ARG_COUNT(args, 3);

    id status = [args objectAtIndex:0];
    id shippingMethods = [args objectAtIndex:1];
    id summaryItems = [args objectAtIndex:2];

    ENSURE_TYPE(status, NSNumber);
    ENSURE_TYPE(shippingMethods, NSArray);
    ENSURE_TYPE(summaryItems, NSArray);

    NSMutableArray *resultShippingMethods = [NSMutableArray array];
    NSMutableArray *resultSummaryItems = [NSMutableArray array];

    for (id item in shippingMethods) {
      ENSURE_TYPE(item, TiApplepayShippingMethodProxy);
      [resultShippingMethods addObject:[(TiApplepayShippingMethodProxy *)item shippingMethod]];
    }

    for (id item in summaryItems) {
      ENSURE_TYPE(item, TiApplepaySummaryItemProxy);
      [resultSummaryItems addObject:[(TiApplepaySummaryItemProxy *)item item]];
    }

    _handler(PKPaymentAuthorizationStatusSuccess, resultShippingMethods, resultSummaryItems);
  }
}

@end
