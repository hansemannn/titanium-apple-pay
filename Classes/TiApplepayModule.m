/**
 * Titanium Apple Pay
 * Copyright (c) 2015-Present by Hans Knoechel. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#import "TiApplepayModule.h"
#import "TiApplepayConstants.h"
#import "TiApplepayPaymentDialogProxy.h"
#import "TiApplepayPaymentRequestProxy.h"
#import <PassKit/PassKit.h>

@implementation TiApplepayModule

#pragma mark Internal

- (id)moduleGUID
{
  return @"50220394-a69d-4820-b11c-7de647935809";
}

- (NSString *)moduleId
{
  return @"ti.applepay";
}

#pragma mark Lifecycle

- (void)startup
{
  [super startup];

  DebugLog(@"[INFO] %@ loaded", self);
}

#pragma mark Public APIs

- (void)setupPaymentGateway:(id)args
{
  ENSURE_SINGLE_ARG(args, NSDictionary);

  id name = [args valueForKey:@"name"];
  id apiKey = [args valueForKey:@"apiKey"];
  ENSURE_TYPE_OR_NIL(name, NSNumber);
  ENSURE_TYPE_OR_NIL(apiKey, NSString);

  if (name == nil) {
    DebugLog(@"[WARN] Ti.ApplePay: Invalid payment gateway set! Apple Pay needs a payment gateway to complete transactions. Will fallback to PAYMENT_GATEWAY_NONE.");
  }

  [[TiApplepayPaymentGatewayConfiguration sharedConfig] setPaymentProvider:[TiUtils intValue:name def:TiApplepayPaymentGatewayNone]];
  [[TiApplepayPaymentGatewayConfiguration sharedConfig] setApiKey:[TiUtils stringValue:apiKey]];
}

- (NSNumber *)isSupported:(id)unused
{
  return @(YES);
}

- (NSNumber *)canMakePayments:(id)args
{
  ENSURE_SINGLE_ARG(args, NSDictionary);

  NSArray *networks = nil;

  if ([args valueForKey:@"networks"]) {
    ENSURE_TYPE([args valueForKey:@"networks"], NSArray);
    networks = [args valueForKey:@"networks"];

    // Capabilities can only be checked together with networks
    if ([args valueForKey:@"capabilities"]) {
      ENSURE_TYPE([args valueForKey:@"capabilities"], NSNumber);
      PKMerchantCapability capabilities = (PKMerchantCapability)[args valueForKey:@"capabilities"];

      return NUMBOOL([PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:networks capabilities:capabilities]);
    }

    return NUMBOOL([PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:networks]);
  }

  return NUMBOOL([PKPaymentAuthorizationViewController canMakePayments]);
}

- (NSNumber *)isPassLibraryAvailable:(id)unused
{
  return NUMBOOL([PKPassLibrary isPassLibraryAvailable]);
}

- (void)openPaymentSetup:(id)unused
{
  PKPassLibrary *lib = [[PKPassLibrary alloc] init];
  [lib openPaymentSetup];
}

#pragma mark Public constants

MAKE_SYSTEM_PROP(PAYMENT_BUTTON_TYPE_PLAIN, PKPaymentButtonTypePlain);
MAKE_SYSTEM_PROP(PAYMENT_BUTTON_TYPE_BUY, PKPaymentButtonTypeBuy);
MAKE_SYSTEM_PROP(PAYMENT_BUTTON_TYPE_SETUP, PKPaymentButtonTypeSetUp);
MAKE_SYSTEM_PROP(PAYMENT_BUTTON_TYPE_IN_STORE, PKPaymentButtonTypeInStore);
MAKE_SYSTEM_PROP(PAYMENT_BUTTON_TYPE_DONATE, PKPaymentButtonTypeDonate);
#if IS_XCODE_10
MAKE_SYSTEM_PROP(PAYMENT_BUTTON_TYPE_CHECKOUT, PKPaymentButtonTypeCheckout);
MAKE_SYSTEM_PROP(PAYMENT_BUTTON_TYPE_BOOK, PKPaymentButtonTypeBook);
MAKE_SYSTEM_PROP(PAYMENT_BUTTON_TYPE_SUBSCRIBE, PKPaymentButtonTypeSubscribe);
#endif

MAKE_SYSTEM_PROP(PAYMENT_BUTTON_STYLE_BLACK, PKPaymentButtonStyleBlack);
MAKE_SYSTEM_PROP(PAYMENT_BUTTON_STYLE_WHITE, PKPaymentButtonStyleWhite);
MAKE_SYSTEM_PROP(PAYMENT_BUTTON_STYLE_WHITE_OUTLINE, PKPaymentButtonStyleWhiteOutline);

MAKE_SYSTEM_PROP(PAYMENT_METHOD_TYPE_CREDIT, PKPaymentMethodTypeCredit);
MAKE_SYSTEM_PROP(PAYMENT_METHOD_TYPE_DEBIT, PKPaymentMethodTypeDebit);
MAKE_SYSTEM_PROP(PAYMENT_METHOD_TYPE_PREPAID, PKPaymentMethodTypePrepaid);
MAKE_SYSTEM_PROP(PAYMENT_METHOD_TYPE_STORE, PKPaymentMethodTypeStore);

MAKE_SYSTEM_PROP(PAYMENT_SUMMARY_ITEM_TYPE_PENDING, PKPaymentSummaryItemTypePending);
MAKE_SYSTEM_PROP(PAYMENT_SUMMARY_ITEM_TYPE_FINAL, PKPaymentSummaryItemTypeFinal);

MAKE_SYSTEM_PROP(PAYMENT_AUTHORIZATION_STATUS_SUCCESS, PKPaymentAuthorizationStatusSuccess);
MAKE_SYSTEM_PROP(PAYMENT_AUTHORIZATION_STATUS_FAILTURE, PKPaymentAuthorizationStatusFailure); // DEPRECATED, kept for backwards compatibility
MAKE_SYSTEM_PROP(PAYMENT_AUTHORIZATION_STATUS_FAILURE, PKPaymentAuthorizationStatusFailure);
MAKE_SYSTEM_PROP(PAYMENT_AUTHORIZATION_STATUS_INVALID_BILLING_POSTAL_ADDRESS, PKPaymentAuthorizationStatusInvalidBillingPostalAddress);
MAKE_SYSTEM_PROP(PAYMENT_AUTHORIZATION_STATUS_INVALID_SHIPPING_POSTAL_ADDRESS, PKPaymentAuthorizationStatusInvalidShippingPostalAddress);
MAKE_SYSTEM_PROP(PAYMENT_AUTHORIZATION_STATUS_INVALID_SHIPPING_CONTACT, PKPaymentAuthorizationStatusInvalidShippingContact);
MAKE_SYSTEM_PROP(PAYMENT_AUTHORIZATION_STATUS_PIN_REQUIRED, PKPaymentAuthorizationStatusPINRequired);
MAKE_SYSTEM_PROP(PAYMENT_AUTHORIZATION_STATUS_PIN_INCORRECT, PKPaymentAuthorizationStatusPINIncorrect);
MAKE_SYSTEM_PROP(PAYMENT_AUTHORIZATION_STATUS_PIN_LOCKOUT, PKPaymentAuthorizationStatusPINLockout);

MAKE_SYSTEM_PROP(PAYMENT_GATEWAY_NONE, TiApplepayPaymentGatewayNone);
MAKE_SYSTEM_PROP(PAYMENT_GATEWAY_STRIPE, TiApplepayPaymentGatewayStripe);
MAKE_SYSTEM_PROP(PAYMENT_GATEWAY_BRAINTREE, TiApplepayPaymentGatewayBraintree);

MAKE_SYSTEM_STR(PAYMENT_NETWORK_AMEX, PKPaymentNetworkAmex);
MAKE_SYSTEM_STR(PAYMENT_NETWORK_DISCOVER, PKPaymentNetworkDiscover);
MAKE_SYSTEM_STR(PAYMENT_NETWORK_MASTERCARD, PKPaymentNetworkMasterCard);
MAKE_SYSTEM_STR(PAYMENT_NETWORK_VISA, PKPaymentNetworkVisa);
MAKE_SYSTEM_STR(PAYMENT_NETWORK_CHINA_UNION_PAY, PKPaymentNetworkChinaUnionPay);
MAKE_SYSTEM_STR(PAYMENT_NETWORK_INTERAC, PKPaymentNetworkInterac);
MAKE_SYSTEM_STR(PAYMENT_NETWORK_PRIVATE_LABEL, PKPaymentNetworkPrivateLabel);
MAKE_SYSTEM_STR(PAYMENT_NETWORK_SUICA, PKPaymentNetworkSuica);
MAKE_SYSTEM_STR(PAYMENT_NETWORK_JCB, PKPaymentNetworkJCB);
MAKE_SYSTEM_STR(PAYMENT_NETWORK_ID_CREDIT, PKPaymentNetworkIDCredit);
MAKE_SYSTEM_STR(PAYMENT_NETWORK_QUIC_PAY, PKPaymentNetworkQuicPay);
MAKE_SYSTEM_STR(PAYMENT_NETWORK_CARTE_BANCAIRE, PKPaymentNetworkCartesBancaires);

MAKE_SYSTEM_PROP(SHIPPING_TYPE_SHIPPING, PKShippingTypeShipping);
MAKE_SYSTEM_PROP(SHIPPING_TYPE_DELIVERY, PKShippingTypeDelivery);
MAKE_SYSTEM_PROP(SHIPPING_TYPE_SERVICE_PICKUP, PKShippingTypeServicePickup);
MAKE_SYSTEM_PROP(SHIPPING_TYPE_STORE_PICKUP, PKShippingTypeStorePickup);

MAKE_SYSTEM_PROP(ADDRESS_FIELD_NONE, PKAddressFieldNone);
MAKE_SYSTEM_PROP(ADDRESS_FIELD_POSTAL_ADDRESS, PKAddressFieldPostalAddress);
MAKE_SYSTEM_PROP(ADDRESS_FIELD_PHONE, PKAddressFieldPhone);
MAKE_SYSTEM_PROP(ADDRESS_FIELD_EMAIL, PKAddressFieldEmail);
MAKE_SYSTEM_PROP(ADDRESS_FIELD_NAME, PKAddressFieldName);
MAKE_SYSTEM_PROP(ADDRESS_FIELD_ALL, PKAddressFieldAll);

MAKE_SYSTEM_PROP(MERCHANT_CAPABILITY_3DS, PKMerchantCapability3DS);
MAKE_SYSTEM_PROP(MERCHANT_CAPABILITY_CREDIT, PKMerchantCapabilityCredit);
MAKE_SYSTEM_PROP(MERCHANT_CAPABILITY_DEBIT, PKMerchantCapabilityDebit);
MAKE_SYSTEM_PROP(MERCHANT_CAPABILITY_EMV, PKMerchantCapabilityEMV);

@end
