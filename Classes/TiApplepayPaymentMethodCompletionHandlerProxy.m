/**
 * Titanium Apple Pay
 * Copyright (c) 2015-Present by Hans Knoechel. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiApplepayPaymentMethodCompletionHandlerProxy.h"
#import "TiApplepaySummaryItemProxy.h"

@implementation TiApplepayPaymentMethodCompletionHandlerProxy

- (void)complete:(id _Nonnull)args
{
  if (_handler != nil) {

    ENSURE_TYPE(args, NSArray);
    ENSURE_ARG_COUNT(args, 1);

    id summaryItems = [args objectAtIndex:0];
    ENSURE_TYPE(summaryItems, NSArray);

    NSMutableArray *resultSummaryItems = [NSMutableArray array];

    for (id item in summaryItems) {
      ENSURE_TYPE(item, TiApplepaySummaryItemProxy);
      [resultSummaryItems addObject:[(TiApplepaySummaryItemProxy *)item item]];
    }

    _handler(resultSummaryItems);
  }
}

@end
