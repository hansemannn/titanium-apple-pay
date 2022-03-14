/**
 * Titanium Apple Pay
 * Copyright (c) 2015-Present by Hans Knoechel. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiApplepayPaymentGatewayConfiguration.h"
@import TitaniumKit;
@import Stripe;

@interface TiApplepayModule : TiModule {
  BOOL usingStripe;
}

- (void)setupPaymentGateway:(id)args;

- (NSNumber *)isSupported:(id)unused;

- (NSNumber *)canMakePayments:(id)args;

@end
