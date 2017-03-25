/**
 * Titanium Apple Pay
 * Copyright (c) 2015-Present by Hans Knoechel. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
#import "TiProxy.h"
#import <PassKit/PassKit.h>

@interface TiApplepaySummaryItemProxy : TiProxy {
    PKPaymentSummaryItem *item;
}

- (void)setType:(id)value;

- (void)setTitle:(id)value;

- (void)setPrice:(id)value;

- (PKPaymentSummaryItem *)item;

@end
