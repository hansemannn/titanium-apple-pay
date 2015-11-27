/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2015 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiApplePayPaymentRequestProxy.h"
#import "TiApplepaySummaryItemProxy.h"
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
        
        /* Test proxy before rebuilding
        TiApplepaySummaryItemProxy *itemProxy = [[TiApplepaySummaryItemProxy alloc] _initWithPageContext:[self pageContext]];
        [itemProxy setTitle:@"Ti.Skateboard"];
        [itemProxy setType:[NSNumber numberWithFloat:0.0]];
        [itemProxy setPrice:[NSNumber numberWithFloat:99.99]];
                
        [paymentRequest setPaymentSummaryItems:@[[itemProxy item],[itemProxy item],[itemProxy item],[itemProxy item],[itemProxy item]]];
         */
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
//    [[self paymentRequest] setMerchantCapabilities:PKMerchantCapability3DS | PKMerchantCapabilityCredit];
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
