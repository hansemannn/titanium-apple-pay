/**
 * Titanium Apple Pay
 * Copyright (c) 2015-Present by Hans Knoechel. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
#import "TiProxy.h"
#import "TiApplepayPaymentRequestProxy.h"

@class PKPaymentAuthorizationViewController;
@class PKPaymentAuthorizationViewControllerDelegate;

@interface TiApplepayPaymentDialogProxy : TiProxy<PKPaymentAuthorizationViewControllerDelegate> {
    PKPaymentAuthorizationViewController *paymentController;
    TiApplepayPaymentRequestProxy *paymentRequestProxy;
}

@end
