/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2015 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiApplePayPaymentRequestProxy.h"
#import "TiApplepaySummaryItemProxy.h"
#import "TiApplepayShippingMethodProxy.h"
#import "TiApp.h"

@implementation TiApplepayPaymentRequestProxy

#pragma mark - Proxy configuration

-(void)dealloc
{
    RELEASE_TO_NIL(paymentRequest);
    [super dealloc];
}

-(PKPaymentRequest*)paymentRequest
{
    if (paymentRequest == nil) {
        paymentRequest = [PKPaymentRequest new];
    }
    
    return paymentRequest;
}

#pragma mark Public APIs

-(void)setMerchantIdentifier:(id)value
{
    ENSURE_TYPE(value, NSString);
    [[self paymentRequest] setMerchantIdentifier:[TiUtils stringValue:value]];
}

-(void)setMerchantCapabilities:(id)args
{
    ENSURE_SINGLE_ARG(args, NSNumber)

    [[self paymentRequest] setMerchantCapabilities:[TiUtils intValue:args]];
}

-(void)setCountryCode:(id)value
{
    ENSURE_TYPE(value, NSString);
    [[self paymentRequest] setCountryCode:[TiUtils stringValue:value]];
}

-(void)setCurrencyCode:(id)value
{
    ENSURE_TYPE(value, NSString);
    [[self paymentRequest] setCurrencyCode:[TiUtils stringValue:value]];
}

-(void)setSupportedNetworks:(id)args
{
    ENSURE_TYPE(args, NSArray);
    
    for (id arg in args) {
        ENSURE_TYPE(arg, NSString);
    }
    
    [[self paymentRequest] setSupportedNetworks:args];
}

-(void)setShippingType:(id)value
{
    ENSURE_TYPE(value, NSNumber);
    
    [[self paymentRequest] setShippingType:[TiUtils intValue:value def:PKShippingTypeShipping]];
}

-(void)setShippingMethods:(id)args
{
    ENSURE_TYPE(args, NSArray);
    NSMutableArray *shippingMethods = [NSMutableArray array];

    for (id arg in args) {
        ENSURE_TYPE(arg, TiApplepayShippingMethodProxy);
        [shippingMethods addObject:[(TiApplepayShippingMethodProxy*)arg shippingMethod]];
    }
    
    [[self paymentRequest] setShippingMethods:shippingMethods];
}

-(void)setRequiredBillingAddressFields:(id)args
{
    ENSURE_TYPE(args, NSNumber);
    
    [[self paymentRequest] setRequiredBillingAddressFields:args];
}

-(void)setRequiredShippingAddressFields:(id)args
{
    ENSURE_TYPE(args, NSNumber);
    
    [[self paymentRequest] setRequiredShippingAddressFields:args];
}

-(void)setApplicationData:(id)args
{
    ENSURE_TYPE(args, NSDictionary);
    [[self paymentRequest] setApplicationData:[NSKeyedArchiver archivedDataWithRootObject:args]];
}

-(void)setSummaryItems:(id)args
{
    ENSURE_TYPE(args, NSArray);
    NSMutableArray *items = [NSMutableArray array];
    
    for(id itemProxy in args) {
        ENSURE_TYPE(itemProxy, TiApplepaySummaryItemProxy);
        [items addObject:[(TiApplepaySummaryItemProxy*)itemProxy item]];
    }
    
    [[self paymentRequest] setPaymentSummaryItems:items];
}

@end
