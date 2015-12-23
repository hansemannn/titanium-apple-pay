/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2015 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiApplepayPaymentDialogProxy.h"
#import "TiApp.h"
#import "TiUtils.h"
#import "TiApplepayConstants.h"
#import "TiApplepayPaymentGatewayConfiguration.h"
#import "TiApplepayShippingMethodCompletionHandlerProxy.h"
#import "TiApplepayShippingContactCompletionHandlerProxy.h"
#import "TiApplepayPaymentMethodCompletionHandlerProxy.h"
#import "TiApplepayPaymentAuthorizationCompletionHandlerProxy.h"
#import <Stripe/Stripe.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@implementation TiApplepayPaymentDialogProxy

-(void)dealloc
{
    RELEASE_TO_NIL(paymentController);
    [super dealloc];
}

-(PKPaymentAuthorizationViewController*)paymentController
{
    if (paymentController == nil) {
        if (paymentRequestProxy == nil) {
            [self throwException:@"⚠️ Trying to initialize a payment dialog without specifying a valid payment request: The paymentRequest property is null! ⚠️" subreason:nil location:CODELOCATION];
            return;
        }
        
        paymentController = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:[paymentRequestProxy paymentRequest]];
        [paymentController setDelegate:self];
    }
    
    return paymentController;
}

#pragma mark - Public APIs

-(void)setPaymentRequest:(id)value
{
    paymentRequestProxy = (TiApplepayPaymentRequestProxy*)value;
    [self replaceValue:value forKey:@"paymentRequest" notification:NO];
}

-(void)show:(id)args
{
    id animated = [args valueForKey:@"animated"];
    ENSURE_TYPE_OR_NIL(animated, NSNumber);
    
    if ([[TiApplepayPaymentGatewayConfiguration sharedConfig] paymentProvider] == TiApplepayPaymentGatewayStripe) {
        DebugLog(@"[DEBUG] Ti.ApplePay: Stripe configured: %@", [Stripe defaultPublishableKey]);
    } else {
        DebugLog(@"[WARN] Ti.ApplePay: ⚠️ No payment gateway configured to process the transaction. ⚠️ ");
    }
    
    if ([self paymentController] == nil) {
        [self throwException:@"⚠️ Payment dialog could not be shown: Looks like the confirguration is invalid! ⚠️" subreason:nil location:CODELOCATION];
        return;
    }
    
    [[[[TiApp app] controller] topPresentedController] presentViewController:[self paymentController] animated:[TiUtils boolValue:animated def:YES] completion:nil];
}

#pragma mark - Apple Pay delegates

-(void)paymentAuthorizationViewControllerWillAuthorizePayment:(PKPaymentAuthorizationViewController *)controller
{
    NSLog(@"[DEBUG] Ti.ApplePay: willAuthorizePayment");

    if ([self _hasListeners:@"willAuthorizePayment"]) {
        [self fireEvent:@"willAuthorizePayment" withObject:nil];
    }
}

-(void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller didAuthorizePayment:(PKPayment *)payment completion:(void (^)(PKPaymentAuthorizationStatus))completion
{
    NSLog(@"[DEBUG] Ti.ApplePay: didAuthorizePayment");
    
    [self handleAuthorizedPayment:payment withCompletionHandler:completion];
}

-(void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller didSelectPaymentMethod:(PKPaymentMethod *)paymentMethod completion:(void (^)(NSArray<PKPaymentSummaryItem *> * _Nonnull))completion
{
    NSLog(@"[DEBUG] Ti.ApplePay: didSelectPayment");
    
    if ([self _hasListeners:@"didSelectPayment"]) {
        
        TiApplepayPaymentMethodCompletionHandlerProxy *handlerProxy = [[TiApplepayPaymentMethodCompletionHandlerProxy alloc] _initWithPageContext:[self pageContext]];
        [handlerProxy setHandler:completion];
        
        [self fireEvent:@"didSelectPayment" withObject:@{
            @"paymentMethod" : NUMINTEGER([paymentMethod type]),
            @"handler" : handlerProxy
        }];
    }
}

-(void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller didSelectShippingContact:(PKContact *)contact completion:(void (^)(PKPaymentAuthorizationStatus, NSArray<PKShippingMethod *> * _Nonnull, NSArray<PKPaymentSummaryItem *> * _Nonnull))completion
{
    NSLog(@"[DEBUG] Ti.ApplePay: didSelectShippingContact");
    
    if ([self _hasListeners:@"didSelectShippingContact"]) {
        
        TiApplepayShippingContactCompletionHandlerProxy *handlerProxy = [[TiApplepayShippingContactCompletionHandlerProxy alloc] _initWithPageContext:[self pageContext]];
        [handlerProxy setHandler:completion];
        
        [self fireEvent:@"didSelectShippingContact" withObject:@{
            @"handler" : handlerProxy,
            @"contact" : [self dictionaryWithPaymentContact:contact]
        }];
    }
}

-(void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller didSelectShippingMethod:(PKShippingMethod *)shippingMethod completion:(void (^)(PKPaymentAuthorizationStatus, NSArray<PKPaymentSummaryItem *> * _Nonnull))completion
{
    NSLog(@"[DEBUG] Ti.ApplePay: didSelectShippingMethod");
    
    if ([self _hasListeners:@"didSelectShippingMethod"]) {
        TiApplepayShippingMethodCompletionHandlerProxy *handlerProxy = [[TiApplepayShippingMethodCompletionHandlerProxy alloc] _initWithPageContext:[self pageContext]];
        [handlerProxy setHandler:completion];

        [self fireEvent:@"didSelectShippingMethod" withObject:@{
            @"identifier" : [shippingMethod identifier],
            @"handler" : handlerProxy
        }];
    }
}

-(void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller
{
    NSLog(@"[DEBUG] Ti.ApplePay: paymentAuthorizationViewControllerDidFinish");

    if ([self _hasListeners:@"close"]) {
        [self fireEvent:@"close" withObject:nil];
    }
    
    [[self paymentController] dismissViewControllerAnimated:YES completion:nil];
    RELEASE_TO_NIL(paymentController);
}

#pragma mark Helper

-(void)handleAuthorizedPayment:(PKPayment *)payment withCompletionHandler:(void (^)(PKPaymentAuthorizationStatus))completion
{
    if (![self _hasListeners:@"didAuthorizePayment"]) {
        [self throwException:@"⚠️ Cannot handle a payment without a 'didAuthorizePayment' eventListener being configured. ⚠️" subreason:nil location:CODELOCATION];
        return;
    }
    
    TiApplepayPaymentAuthorizationCompletionHandlerProxy *handlerProxy = [[TiApplepayPaymentAuthorizationCompletionHandlerProxy alloc] _initWithPageContext:[self pageContext]];
    [handlerProxy setHandler:completion];
    
    /**
     *  TODO: Move to own payment gateway handler.
     */
    if ([[TiApplepayPaymentGatewayConfiguration sharedConfig] paymentProvider] == TiApplepayPaymentGatewayStripe) {
        DebugLog(@"[INFO] Ti.ApplePay: Stripe payment gateway configured. Completing payment ...");
        
        [[STPAPIClient sharedClient] createTokenWithPayment:payment completion:^(STPToken *token, NSError *error) {
            if (error) {
                [self fireEvent:@"didAuthorizePayment" withObject:@{
                    @"success": NUMBOOL(NO),
                    @"handler": handlerProxy
                }];
                
                return;
            }
            
            [self fireEvent:@"didAuthorizePayment" withObject:@{
                @"success": NUMBOOL(YES),
                @"handler": handlerProxy,
                @"payment": [self dictionaryWithPayment:payment],
                @"stripeTokenId": token.tokenId
            }];
        }];
    } else {
        [self throwException:@"⚠️ No payment gateway configured! ⚠️" subreason:nil location:CODELOCATION];
        completion(PKPaymentAuthorizationStatusFailure);
    }
}

-(NSDictionary *)dictionaryWithPaymentContact:(PKContact*)contact
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        @"prefix": [self proxyValueFromContactValue:[[contact name] namePrefix]],
        @"firstName": [self proxyValueFromContactValue:[[contact name] givenName]],
        @"middleName": [self proxyValueFromContactValue:[[contact name] middleName]],
        @"lastName": [self proxyValueFromContactValue:[[contact name] familyName]],
        @"suffix": [self proxyValueFromContactValue:[[contact name] nameSuffix]],
        @"email": [self proxyValueFromContactValue:[contact emailAddress]],
        @"phone": [self proxyValueFromContactValue:[[contact phoneNumber] stringValue]],
        @"address": @{
            @"street": [self proxyValueFromContactValue:[[contact postalAddress] street]],
            @"postalCode": [self proxyValueFromContactValue:[[contact postalAddress] postalCode]],
            @"city": [self proxyValueFromContactValue:[[contact postalAddress] city]],
            @"state": [self proxyValueFromContactValue:[[contact postalAddress] state]],
            @"country": [self proxyValueFromContactValue:[[contact postalAddress] country]]
        }
    }];
    
#if __IPHONE_9_2
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.2")) {
        [dict setValue:[self proxyValueFromContactValue:[self proxyValueFromContactValue:[contact supplementarySubLocality]]] forKey:@"supplementarySubLocality"];
    }
#endif
    
    return dict;
}

-(NSDictionary *)dictionaryWithPayment:(PKPayment *)payment
{
    return @{
        @"transactionIdentifier" : payment.token.transactionIdentifier,
        @"paymentData" : [[TiBlob alloc] initWithData:payment.token.paymentData mimetype:@"text/json"],
    };
}

-(id)proxyValueFromContactValue:(id)value
{
    if (value == nil) {
        return [NSNull null];
    }
    
    return value;
}

@end
