/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2015 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiApplepayPaymentGatewayConfiguration.h"
#import <Stripe/Stripe.h>

@implementation TiApplepayPaymentGatewayConfiguration

+ (id)sharedConfig {
    static TiApplepayPaymentGatewayConfiguration *sharedConfig = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedConfig = [[self alloc] init];
    });
    return sharedConfig;
}

- (id)init {
    if (self = [super init]) {
        _paymentProvider = TiApplepayPaymentGatewayNone;
    }
    return self;
}

-(void)setPaymentProvider:(TiApplepayPaymentGateway)paymentProvider
{
    _paymentProvider = paymentProvider;
}

-(void)setApiKey:(NSString *)apiKey
{
    _apiKey = [apiKey retain];
    [self setupProvider];
}

-(void)setupProvider
{
    if ([self paymentProvider] == TiApplepayPaymentGatewayStripe) {
        [Stripe setDefaultPublishableKey:[self apiKey]];
    } else if ([self paymentProvider] == TiApplepayPaymentGatewayChase) {
        
    }
}

@end