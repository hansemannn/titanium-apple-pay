/**
 * Titanium Apple Pay
 * Copyright (c) 2015-Present by Hans Knoechel. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
#import "TiProxy.h"
#import <PassKit/PassKit.h>

@interface TiApplepayShippingMethodProxy : TiProxy {
    PKShippingMethod *shippingMethod;
}

- (void)setTitle:(id)value;

- (void)setIdentifier:(id)value;

- (void)setDescription:(id)value;

- (void)setPrice:(id)value;

- (PKShippingMethod *)shippingMethod;

@end
