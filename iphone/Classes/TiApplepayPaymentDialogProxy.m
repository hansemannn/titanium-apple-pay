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
            return nil;
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
    ENSURE_UI_THREAD(show, args);
    id animated = [args valueForKey:@"animated"];
    ENSURE_TYPE_OR_NIL(animated, NSNumber);
    
    switch ([[TiApplepayPaymentGatewayConfiguration sharedConfig] paymentProvider]) {
        case TiApplepayPaymentGatewayStripe:
            NSLog(@"[DEBUG] Ti.ApplePay: Stripe configured: %@", [Stripe defaultPublishableKey]);
            break;

        case TiApplepayPaymentGatewayNone:
        default:
            NSLog(@"[DEBUG] Ti.ApplePay: No payment provider selected, using own gateway.");
            break;
    }
    
    if (![self paymentController]) {
        [self throwException:@"⚠️ Payment dialog could not be shown: Looks like the configuration is invalid! ⚠️" subreason:nil location:CODELOCATION];
        return;
    }
    
    [[TiApp app] showModalController:[self paymentController] animated:[TiUtils boolValue:animated def:YES]];
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
    
    [[TiApp app] hideModalController:paymentController animated:YES];
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
        NSLog(@"[DEBUG] Ti.ApplePay: Stripe payment gateway configured. Completing payment ...");
        
        [[STPAPIClient sharedClient] createTokenWithPayment:payment completion:^(STPToken *token, NSError *error) {
            if (error) {
                [self fireEvent:@"didAuthorizePayment" withObject:@{
                    @"success": NUMBOOL(NO),
                    @"handler": handlerProxy,
                    @"error": [error localizedDescription],
                    @"code": NUMINTEGER([error code])
                }];
                
                return;
            }
            
            [self fireEvent:@"didAuthorizePayment" withObject:@{
                @"success": NUMBOOL(YES),
                @"handler": handlerProxy,
                @"payment": [self dictionaryWithPayment:payment],
                @"created": token.created,
                @"stripeTokenId": [self proxyValueFromValue:token.tokenId]
            }];
        }];
    } else if ([[TiApplepayPaymentGatewayConfiguration sharedConfig] paymentProvider] == TiApplepayPaymentGatewayNone) {
        NSLog(@"[DEBUG] Ti.ApplePay: No payment provider configured, Completing payment ...");
        
        [self fireEvent:@"didAuthorizePayment" withObject:@{
            @"success": NUMBOOL(YES),
            @"handler": handlerProxy,
            @"payment": [self dictionaryWithPayment:payment]
        }];
    } else {
        [self throwException:@"⚠️ No payment gateway configured! ⚠️" subreason:nil location:CODELOCATION];
        completion(PKPaymentAuthorizationStatusFailure);
    }
}

-(NSDictionary *)dictionaryWithPaymentContact:(PKContact*)contact
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        @"prefix": [self proxyValueFromValue:[[contact name] namePrefix]],
        @"firstName": [self proxyValueFromValue:[[contact name] givenName]],
        @"middleName": [self proxyValueFromValue:[[contact name] middleName]],
        @"lastName": [self proxyValueFromValue:[[contact name] familyName]],
        @"suffix": [self proxyValueFromValue:[[contact name] nameSuffix]],
        @"email": [self proxyValueFromValue:[contact emailAddress]],
        @"phone": [self proxyValueFromValue:[[contact phoneNumber] stringValue]],
        @"address": @{
            @"street": [self proxyValueFromValue:[[contact postalAddress] street]],
            @"postalCode": [self proxyValueFromValue:[[contact postalAddress] postalCode]],
            @"city": [self proxyValueFromValue:[[contact postalAddress] city]],
            @"state": [self proxyValueFromValue:[[contact postalAddress] state]],
            @"country": [self proxyValueFromValue:[[contact postalAddress] country]]
        }
    }];
    
#if __IPHONE_9_2
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.2")) {
        [dict setValue:[self proxyValueFromValue:[contact supplementarySubLocality]] forKey:@"supplementarySubLocality"];
    }
#endif
    
    return dict;
}

-(NSDictionary *)dictionaryWithPayment:(PKPayment *)payment
{
    return @{
        @"paymentNetwork" : [self proxyValueFromValue:payment.token.paymentNetwork],
        @"paymentInstrumentName" : [self proxyValueFromValue:payment.token.paymentInstrumentName],
        @"paymentMethod" : NUMUINT(payment.token.paymentMethod.type),
        @"transactionIdentifier" : [self proxyValueFromValue:payment.token.transactionIdentifier],
        @"paymentData" : payment.token.paymentData ? [[[TiBlob alloc] initWithData:payment.token.paymentData mimetype:@"text/json"] autorelease] : [NSNull null],
    };
}

-(id)proxyValueFromValue:(id)value
{
    if (value == nil) {
        return [NSNull null];
    }
    
    return value;
}

@end
