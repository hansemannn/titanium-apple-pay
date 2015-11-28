/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2015 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
#import "TiProxy.h"
#import "TiApplepayPaymentRequestProxy.h"
#import <Passkit/Passkit.h>
#import <Stripe/Stripe.h>

@interface TiApplepayPaymentDialogProxy : TiProxy<PKPaymentAuthorizationViewControllerDelegate> {
    PKPaymentAuthorizationViewController *paymentController;
    TiApplepayPaymentRequestProxy *paymentRequestProxy;
}

@end
