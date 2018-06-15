/**
 * Titanium Apple Pay
 * Copyright (c) 2015-Present by Hans Knoechel. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiApplepayPaymentRequestProxy.h"
#import "TiApp.h"
#import "TiApplepayContact.h"
#import "TiApplepayShippingMethodProxy.h"
#import "TiApplepaySummaryItemProxy.h"

#ifdef USE_TI_CONTACTSPERSON
#import "TiContactsPerson.h"
#endif

@implementation TiApplepayPaymentRequestProxy

#pragma mark - Proxy configuration

- (PKPaymentRequest *)paymentRequest
{
  if (paymentRequest == nil) {
    paymentRequest = [PKPaymentRequest new];
  }

  return paymentRequest;
}

#pragma mark Public APIs

- (NSArray *)availableNetworks:(id)unused
{
  if ([TiUtils isIOSVersionOrGreater:@"10.0"]) {
    return [PKPaymentRequest availableNetworks];
  } else {
    return @[];
  }
}

- (void)setMerchantIdentifier:(id)value
{
  ENSURE_TYPE(value, NSString);
  [[self paymentRequest] setMerchantIdentifier:[TiUtils stringValue:value]];
  [self replaceValue:value forKey:@"merchantIdentifier" notification:NO];
}

- (void)setMerchantCapabilities:(id)args
{
  ENSURE_SINGLE_ARG(args, NSNumber);
  [[self paymentRequest] setMerchantCapabilities:[TiUtils intValue:args]];
  [self replaceValue:args forKey:@"merchantCapabilities" notification:NO];
}

- (void)setCountryCode:(id)value
{
  ENSURE_TYPE(value, NSString);
  [[self paymentRequest] setCountryCode:[TiUtils stringValue:value]];
  [self replaceValue:value forKey:@"countryCode" notification:NO];
}

- (void)setCurrencyCode:(id)value
{
  ENSURE_TYPE(value, NSString);
  [[self paymentRequest] setCurrencyCode:[TiUtils stringValue:value]];
  [self replaceValue:value forKey:@"currencyCode" notification:NO];
}

- (void)setSupportedNetworks:(id)args
{
  ENSURE_TYPE(args, NSArray);

  for (id arg in args) {
    ENSURE_TYPE(arg, NSString);
  }

  [[self paymentRequest] setSupportedNetworks:args];
  [self replaceValue:args forKey:@"supportedNetworks" notification:NO];
}

- (void)setShippingType:(id)value
{
  ENSURE_TYPE(value, NSNumber);

  [[self paymentRequest] setShippingType:[TiUtils intValue:value def:PKShippingTypeShipping]];
  [self replaceValue:value forKey:@"shippingType" notification:NO];
}

- (void)setShippingMethods:(id)args
{
  ENSURE_TYPE(args, NSArray);
  NSMutableArray *shippingMethods = [NSMutableArray array];

  for (id arg in args) {
    ENSURE_TYPE(arg, TiApplepayShippingMethodProxy);
    [shippingMethods addObject:[(TiApplepayShippingMethodProxy *)arg shippingMethod]];
  }

  [[self paymentRequest] setShippingMethods:shippingMethods];
  [self replaceValue:args forKey:@"shippingMethods" notification:NO];
}

- (void)setShippingContact:(id)value
{
  [[self paymentRequest] setShippingContact:(PKContact *)[self contactFromProxy:value]];
  [self replaceValue:value forKey:@"shippingContact" notification:NO];
}

- (void)setBillingContact:(id)value
{
  [[self paymentRequest] setBillingContact:[self contactFromProxy:value]];
  [self replaceValue:value forKey:@"billingContact" notification:NO];
}

- (void)setRequiredBillingAddressFields:(id)args
{
  ENSURE_TYPE(args, NSNumber);

  [[self paymentRequest] setRequiredBillingAddressFields:(PKAddressField)args];
  [self replaceValue:args forKey:@"requiredBillingAddressFields" notification:NO];
}

- (void)setRequiredShippingAddressFields:(id)args
{
  ENSURE_TYPE(args, NSNumber);

  [[self paymentRequest] setRequiredShippingAddressFields:(PKAddressField)args];
  [self replaceValue:args forKey:@"requiredShippingAddressFields" notification:NO];
}

- (void)setApplicationData:(id)args
{
  ENSURE_TYPE(args, NSDictionary);
  [[self paymentRequest] setApplicationData:[NSKeyedArchiver archivedDataWithRootObject:args]];
  [self replaceValue:args forKey:@"applicationData" notification:NO];
}

- (void)setSummaryItems:(id)args
{
  ENSURE_TYPE(args, NSArray);
  NSMutableArray *items = [NSMutableArray array];

  for (id itemProxy in args) {
    ENSURE_TYPE(itemProxy, TiApplepaySummaryItemProxy);
    [items addObject:[(TiApplepaySummaryItemProxy *)itemProxy item]];
  }

  [[self paymentRequest] setPaymentSummaryItems:items];
  [self replaceValue:args forKey:@"summaryItems" notification:NO];
}

#pragma mark Helper

- (PKContact *)contactFromProxy:(id)proxy
{
  PKContact *contact = nil;

  if ([proxy isKindOfClass:[NSDictionary class]]) {
    contact = [[TiApplepayContact alloc] initWithDictionary:proxy];
  }
#ifdef USE_TI_CONTACTSPERSON
  else if ([proxy isKindOfClass:[TiContactsPerson class]]) {
    contact = [[TiApplepayContact alloc] TiApplePay_initWithPerson:(TiContactsPerson *)proxy];
  }
#endif
  else {
    [self throwException:@"Invalid contact type provided." subreason:@"The contact must either be an Object (recommended) or a TiContacts Person." location:CODELOCATION];
  }

  return contact;
}

@end
