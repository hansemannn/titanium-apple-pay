/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2015 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "TiApplepayModule.h"
#import "TiApplepayPaymentRequestProxy.h"
#import "TiApplepayPaymentDialogProxy.h"
#import "TiApplepayConstants.h"
#import <PassKit/PassKit.h>
#import <Stripe/Stripe.h>

@implementation TiApplepayModule

#pragma mark Internal

-(id)moduleGUID
{
	return @"50220394-a69d-4820-b11c-7de647935809";
}

-(NSString*)moduleId
{
	return @"ti.applepay";
}

#pragma mark Lifecycle

-(void)startup
{
	[super startup];

	NSLog(@"[INFO] %@ loaded",self);
}

#pragma mark Public APIs

-(void)setupPaymentGateway:(id)args
{
    args = [args objectAtIndex:0];
    ENSURE_TYPE(args, NSDictionary);
    
    id name = [args valueForKey:@"name"];
    id apiKey = [args valueForKey:@"apiKey"];
    ENSURE_TYPE_OR_NIL(name, NSNumber);
    ENSURE_TYPE_OR_NIL(apiKey, NSString);
    
    if (name == nil) {
        NSLog(@"[WARN] Ti.ApplePay: Invalid payment gateway set! Apple Pay needs a payment gateway to complete transactions. Will fallback to PAYMENT_GATEWAY_NONE.");
    }

    [[TiApplepayPaymentGatewayConfiguration sharedConfig] setPaymentProvider:[TiUtils intValue:name def:TiApplepayPaymentGatewayNone]];
    [[TiApplepayPaymentGatewayConfiguration sharedConfig] setApiKey:[TiUtils stringValue:apiKey]];
}

-(NSNumber*)isSupported:(id)unused
{
    return NUMBOOL([TiUtils isIOS9OrGreater] == YES);
}

-(NSNumber*)canMakePayments:(id)args
{
    NSArray *networks = nil;
    PKMerchantCapability capabilities = nil;
    
    if ([args valueForKey:@"networks"]) {
        ENSURE_TYPE([args valueForKey:@"networks"], NSArray);
        networks = [args valueForKey:@"networks"];
        
        // Capabilities can only be checked together with networks
        if ([args valueForKey:@"capabilities"]) {
            ENSURE_TYPE([args valueForKey:@"capabilities"], NSArray);
            capabilities = [args valueForKey:@"capabilities"];
        }
    }
    
    if (networks != nil && capabilities) {
        return  NUMBOOL([PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:networks capabilities:capabilities]);
    } else if (networks != nil && !capabilities) {
        return NUMBOOL([PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:networks]);
    }
    
    return NUMBOOL([PKPaymentAuthorizationViewController canMakePayments]);
}

-(NSNumber*)isPassLibraryAvailable:(id)unused
{
    return NUMBOOL([PKPassLibrary isPassLibraryAvailable]);
}

-(void)openPaymentSetup:(id)unused
{
    PKPassLibrary *lib = [[[PKPassLibrary alloc] init] autorelease];
    [lib openPaymentSetup];
}

#pragma mark Public constants

MAKE_SYSTEM_PROP(PAYMENT_BUTTON_TYPE_PLAIN,                                     PKPaymentButtonTypePlain);
MAKE_SYSTEM_PROP(PAYMENT_BUTTON_TYPE_BUY,                                       PKPaymentButtonTypeBuy);
MAKE_SYSTEM_PROP(PAYMENT_BUTTON_TYPE_SETUP,                                     PKPaymentButtonTypeSetUp);

#ifdef __IPHONE_10_0
-(NSNumber*)PAYMENT_BUTTON_TYPE_IN_STORE
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")) {
        return NUMINTEGER(PKPaymentButtonTypeInStore);
    } else {
        return nil;
    }
}
#endif

#if __IPHONE_10_2
-(NSNumber*)PAYMENT_BUTTON_TYPE_DONATE
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.2")) {
        return NUMINTEGER(PKPaymentButtonTypeDonate);
    } else {
        return nil;
    }
}
#endif

MAKE_SYSTEM_PROP(PAYMENT_BUTTON_STYLE_BLACK,                                    PKPaymentButtonStyleBlack);
MAKE_SYSTEM_PROP(PAYMENT_BUTTON_STYLE_WHITE,                                    PKPaymentButtonStyleWhite);
MAKE_SYSTEM_PROP(PAYMENT_BUTTON_STYLE_WHITE_OUTLINE,                            PKPaymentButtonStyleWhiteOutline);

MAKE_SYSTEM_PROP(PAYMENT_METHOD_TYPE_CREDIT,                                    PKPaymentMethodTypeCredit);
MAKE_SYSTEM_PROP(PAYMENT_METHOD_TYPE_DEBIT,                                     PKPaymentMethodTypeDebit);
MAKE_SYSTEM_PROP(PAYMENT_METHOD_TYPE_PREPAID,                                   PKPaymentMethodTypePrepaid);
MAKE_SYSTEM_PROP(PAYMENT_METHOD_TYPE_STORE,                                     PKPaymentMethodTypeStore);

MAKE_SYSTEM_PROP(PAYMENT_SUMMARY_ITEM_TYPE_PENDING,                             PKPaymentSummaryItemTypePending);
MAKE_SYSTEM_PROP(PAYMENT_SUMMARY_ITEM_TYPE_FINAL,                               PKPaymentSummaryItemTypeFinal);

MAKE_SYSTEM_PROP(PAYMENT_AUTHORIZATION_STATUS_SUCCESS,                          PKPaymentAuthorizationStatusSuccess);
MAKE_SYSTEM_PROP(PAYMENT_AUTHORIZATION_STATUS_FAILTURE,                         PKPaymentAuthorizationStatusFailure);
MAKE_SYSTEM_PROP(PAYMENT_AUTHORIZATION_STATUS_INVALID_BILLING_POSTAL_ADDRESS,   PKPaymentAuthorizationStatusInvalidBillingPostalAddress);
MAKE_SYSTEM_PROP(PAYMENT_AUTHORIZATION_STATUS_INVALID_SHIPPING_POSTAL_ADDRESS,  PKPaymentAuthorizationStatusInvalidShippingPostalAddress);
MAKE_SYSTEM_PROP(PAYMENT_AUTHORIZATION_STATUS_INVALID_SHIPPING_CONTACT,         PKPaymentAuthorizationStatusInvalidShippingContact);

#if __IPHONE_9_2
-(NSNumber*)PAYMENT_AUTHORIZATION_STATUS_PIN_REQUIRED
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.2")) {
        return [NSNumber numberWithInt:PKPaymentAuthorizationStatusPINRequired];
    }
}

-(NSNumber*)PAYMENT_AUTHORIZATION_STATUS_PIN_INCORRECT
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.2")) {
        return [NSNumber numberWithInt:PKPaymentAuthorizationStatusPINIncorrect];
    }
}

-(NSNumber*)PAYMENT_AUTHORIZATION_STATUS_PIN_LOCKOUT
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.2")) {
        return [NSNumber numberWithInt:PKPaymentAuthorizationStatusPINLockout];
    }
}
#endif

MAKE_SYSTEM_PROP(PAYMENT_GATEWAY_NONE,                                          TiApplepayPaymentGatewayNone);
MAKE_SYSTEM_PROP(PAYMENT_GATEWAY_STRIPE,                                        TiApplepayPaymentGatewayStripe);
MAKE_SYSTEM_PROP(PAYMENT_GATEWAY_CHASE,                                         TiApplepayPaymentGatewayChase);

MAKE_SYSTEM_STR(PAYMENT_NETWORK_AMEX,                                           PKPaymentNetworkAmex);
MAKE_SYSTEM_STR(PAYMENT_NETWORK_DISCOVER,                                       PKPaymentNetworkDiscover);
MAKE_SYSTEM_STR(PAYMENT_NETWORK_MASTERCARD,                                     PKPaymentNetworkMasterCard);
MAKE_SYSTEM_STR(PAYMENT_NETWORK_VISA,                                           PKPaymentNetworkVisa);
MAKE_SYSTEM_STR(PAYMENT_NETWORK_CHINA_UNION_PAY,                                PKPaymentNetworkChinaUnionPay);
MAKE_SYSTEM_STR(PAYMENT_NETWORK_INTERAC,                                        PKPaymentNetworkInterac);
MAKE_SYSTEM_STR(PAYMENT_NETWORK_PRIVATE_LABEL,                                  PKPaymentNetworkPrivateLabel);

#if __IPHONE_10_1
-(NSNumber*)PAYMENT_NETWORK_SUICA
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.1")) {
        return NUMINTEGER(PKPaymentNetworkSuica);
    } else {
        return nil;
    }
}

-(NSNumber*)PAYMENT_NETWORK_JCB
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.1")) {
        return NUMINTEGER(PKPaymentNetworkJCB);
    } else {
        return nil;
    }
}
#endif

#if __IPHONE_10_3
-(NSNumber*)PAYMENT_NETWORK_ID
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.3")) {
        return NUMINTEGER(PKPaymentNetworkiD);
    } else {
        return nil;
    }
}

-(NSNumber*)PAYMENT_NETWORK_QUIC_PAY
{
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.3")) {
        return NUMINTEGER(PKPaymentNetworkQuicPay);
    } else {
        return nil;
    }
}
#endif

MAKE_SYSTEM_PROP(SHIPPING_TYPE_SHIPPING,                                        PKShippingTypeShipping);
MAKE_SYSTEM_PROP(SHIPPING_TYPE_DELIVERY,                                        PKShippingTypeDelivery);
MAKE_SYSTEM_PROP(SHIPPING_TYPE_SERVICE_PICKUP,                                  PKShippingTypeServicePickup);
MAKE_SYSTEM_PROP(SHIPPING_TYPE_STORE_PICKUP,                                    PKShippingTypeStorePickup);

MAKE_SYSTEM_PROP(ADDRESS_FIELD_NONE,                                            PKAddressFieldNone);
MAKE_SYSTEM_PROP(ADDRESS_FIELD_POSTAL_ADDRESS,                                  PKAddressFieldPostalAddress);
MAKE_SYSTEM_PROP(ADDRESS_FIELD_PHONE,                                           PKAddressFieldPhone);
MAKE_SYSTEM_PROP(ADDRESS_FIELD_EMAIL,                                           PKAddressFieldEmail);
MAKE_SYSTEM_PROP(ADDRESS_FIELD_NAME,                                            PKAddressFieldName);
MAKE_SYSTEM_PROP(ADDRESS_FIELD_ALL,                                             PKAddressFieldAll);

MAKE_SYSTEM_PROP(MERCHANT_CAPABILITY_3DS,                                       PKMerchantCapability3DS);
MAKE_SYSTEM_PROP(MERCHANT_CAPABILITY_CREDIT,                                    PKMerchantCapabilityCredit);
MAKE_SYSTEM_PROP(MERCHANT_CAPABILITY_DEBIT,                                     PKMerchantCapabilityDebit);
MAKE_SYSTEM_PROP(MERCHANT_CAPABILITY_EMV,                                       PKMerchantCapabilityEMV);

@end
