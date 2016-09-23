/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2015 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiApp.h"
#import "TiApplePayPaymentRequestProxy.h"
#import "TiApplepaySummaryItemProxy.h"
#import "TiApplepayShippingMethodProxy.h"
#import "TiApplepayContact.h"

#ifdef USE_TI_CONTACTS
#import "TiContactsPerson.h"
#endif

@implementation TiApplepayPaymentRequestProxy

#pragma mark - Proxy configuration

-(void)dealloc
{
    RELEASE_TO_NIL(paymentRequest);
    [super dealloc];
}

-(PKPaymentRequest *)paymentRequest
{
    if (paymentRequest == nil) {
        paymentRequest = [PKPaymentRequest new];
    }
    
    return paymentRequest;
}

#pragma mark Public APIs

#ifdef __IPHONE_10_0
-(NSArray*)availableNetworks:(id)unused
{
    if ([TiUtils isIOS10OrGreater]) {
        return [PKPaymentRequest availableNetworks];
    } else {
        return @[];
    }
}
#endif

-(void)setMerchantIdentifier:(id)value
{
    ENSURE_TYPE(value, NSString);
    [[self paymentRequest] setMerchantIdentifier:[TiUtils stringValue:value]];
    [self replaceValue:value forKey:@"merchantIdentifier" notification:NO];
}

-(void)setMerchantCapabilities:(id)args
{
    ENSURE_SINGLE_ARG(args, NSNumber);
    [[self paymentRequest] setMerchantCapabilities:[TiUtils intValue:args]];
    [self replaceValue:args forKey:@"merchantCapabilities" notification:NO];
}

-(void)setCountryCode:(id)value
{
    ENSURE_TYPE(value, NSString);
    [[self paymentRequest] setCountryCode:[TiUtils stringValue:value]];
    [self replaceValue:value forKey:@"countryCode" notification:NO];
}

-(void)setCurrencyCode:(id)value
{
    ENSURE_TYPE(value, NSString);
    [[self paymentRequest] setCurrencyCode:[TiUtils stringValue:value]];
    [self replaceValue:value forKey:@"currencyCode" notification:NO];
}

-(void)setSupportedNetworks:(id)args
{
    ENSURE_TYPE(args, NSArray);
    
    for (id arg in args) {
        ENSURE_TYPE(arg, NSString);
    }
    
    [[self paymentRequest] setSupportedNetworks:args];
    [self replaceValue:args forKey:@"supportedNetworks" notification:NO];
}

-(void)setShippingType:(id)value
{
    ENSURE_TYPE(value, NSNumber);
    
    [[self paymentRequest] setShippingType:[TiUtils intValue:value def:PKShippingTypeShipping]];
    [self replaceValue:value forKey:@"shippingType" notification:NO];
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
    [self replaceValue:args forKey:@"shippingMethods" notification:NO];
}

-(void)setShippingContact:(id)value
{
    [[self paymentRequest] setShippingContact:[self contactFromProxy:value]];
    [self replaceValue:value forKey:@"shippingContact" notification:NO];
}

-(void)setBillingContact:(id)value
{
    [[self paymentRequest] setBillingContact:[self contactFromProxy:value]];
    [self replaceValue:value forKey:@"billingContact" notification:NO];
}

-(void)setRequiredBillingAddressFields:(id)args
{
    ENSURE_TYPE(args, NSNumber);
    
    [[self paymentRequest] setRequiredBillingAddressFields:args];
    [self replaceValue:args forKey:@"requiredBillingAddressFields" notification:NO];
}

-(void)setRequiredShippingAddressFields:(id)args
{
    ENSURE_TYPE(args, NSNumber);
    
    [[self paymentRequest] setRequiredShippingAddressFields:args];
    [self replaceValue:args forKey:@"requiredShippingAddressFields" notification:NO];
}

-(void)setApplicationData:(id)args
{
    ENSURE_TYPE(args, NSDictionary);
    [[self paymentRequest] setApplicationData:[NSKeyedArchiver archivedDataWithRootObject:args]];
    [self replaceValue:args forKey:@"applicationData" notification:NO];
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
    [self replaceValue:args forKey:@"summaryItems" notification:NO];
}

#pragma mark Helper

-(PKContact *)contactFromProxy:(id)proxy
{
    PKContact *contact = nil;
    
    if ([proxy isKindOfClass:[NSDictionary class]]) {
        contact = [[TiApplepayContact alloc] initWithDictionary:proxy];
    }
#ifdef USE_TI_CONTACTS
    else if ([proxy isKindOfClass:[TiContactsPerson class]]) {
        contact = [[TiApplepayContact alloc] TiApplePay_initWithPerson:(TiContactsPerson*)proxy];
    }
#endif
    
    if (contact == nil) {
        [self throwException:@"Invalid contact type provided." subreason:@"The contact must either be an Object (recommended) or a Ti.Contacts.Person." location:CODELOCATION];
    }
    
    return contact;
}

@end
