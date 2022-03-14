/**
 * Titanium Apple Pay
 * Copyright (c) 2015-Present by Hans Knoechel. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
#import <PassKit/PassKit.h>
@import TitaniumKit;

@interface TiApplepayShippingMethodCompletionHandlerProxy : TiProxy {
}

@property (nonatomic, copy) void (^_Nonnull handler)(PKPaymentAuthorizationStatus, NSArray<PKPaymentSummaryItem *> *_Nonnull);

- (void)complete:(id _Nonnull)args;

@end
