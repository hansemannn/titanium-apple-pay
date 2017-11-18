/**
 * Titanium Apple Pay
 * Copyright (c) 2015-Present by Hans Knoechel. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
#import "TiUIView.h"
#import <PassKit/PassKit.h>

@interface TiApplepayPaymentButton : TiUIView {
  @private
  PKPaymentButton *paymentButton;
}

- (PKPaymentButton *)paymentButton;

@end
