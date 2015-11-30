/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2015 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiApplepayPaymentDialogProxy.h"
#import "TiApp.h"
#import "TiApplepayConstants.h"
#import "TiApplepayPaymentGatewayConfiguration.h"
#import "TiApplepayShippingMethodCompletionHandlerProxy.h"
#import "TiApplepayShippingContactCompletionHandlerProxy.h"
#import "TiApplepayPaymentMethodCompletionHandlerProxy.h"
#import <Stripe/Stripe.h>

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
            [self throwException:@"⚠️ Trying to initialize a payment dialog without specifying a payment request: The paymentRequest property is null! ⚠️" subreason:nil location:CODELOCATION];
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
        
        // TODO: Write proxy for PKContact to handle change
        [self fireEvent:@"didSelectShippingContact" withObject:@{
            @"handler" : handlerProxy
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
        DebugLog(@"[WARN] Ti.ApplePay: ⚠️ No 'didAuthorizePayment' event listener configured. ⚠️");
    }
    
    /**
     *  TODO: Move to own payment gateway handler.
     */
    if ([[TiApplepayPaymentGatewayConfiguration sharedConfig] paymentProvider] == TiApplepayPaymentGatewayStripe) {
        DebugLog(@"[INFO] Ti.ApplePay: Stripe payment gateway configured. Completing payment ...");
        
        [[STPAPIClient sharedClient] createTokenWithPayment:payment completion:^(STPToken *token, NSError *error) {
            if (error) {
                [self fireEvent:@"didAuthorizePayment" withObject:@{@"success": NUMBOOL(NO)}];
                completion(PKPaymentAuthorizationStatusFailure);
                return;
            }
            
            [self fireEvent:@"didAuthorizePayment" withObject:@{@"success": NUMBOOL(YES)}];
            completion(PKPaymentAuthorizationStatusSuccess);
            
        }];
    } /*else if([[TiApplepayPaymentGatewayConfiguration sharedConfig] paymentProvider] == TiApplepayPaymentGatewayChase) {
        DebugLog(@"[WARN] Ti.ApplePay: ⚠️ Chase payments are not possible, yet. ⚠️");

        CPSGateway *gateway = [[CPSGateway alloc] init];
        
        gateway.test = YES;
        
        CPSAuthorizationRequest *request = [[CPSAuthorizationRequest alloc] initWithPaymentData:payment.token.paymentData];
        
        request.orderId = [NSString stringWithFormat:@"%ld", arc4random()%9000 + 10000000000];
        request.billingAddress = [[CPSBillingAddress alloc] init];
        request.billingAddress.postalCode = @"33333";
        request.capture = NO;
        
        [gateway authorizePaymentWithRequest:request withCompletionHandler:^(CPSAuthorizationResponse *response, NSError *error) {
            if(error != nil) {
                [self fireEvent:@"didAuthorizePayment" withObject:@{@"success": NUMBOOL(NO)}];
            } else {
                if([response.procStatus isEqualToString:@"0"] && [response.respCode isEqualToString:@"00"]) {
                    [self fireEvent:@"didAuthorizePayment" withObject:@{@"success": NUMBOOL(YES)}];
                    completion(PKPaymentAuthorizationStatusSuccess);
                    return;
                } else {
                    [self fireEvent:@"didAuthorizePayment" withObject:@{@"success": NUMBOOL(NO)}];
                }
            }
            completion(PKPaymentAuthorizationStatusFailure);
            
        }];
    } */ else {
        DebugLog(@"[WARN] Ti.ApplePay: ⚠️ No payment gateway configured, skipping ... ⚠️");
        completion(PKPaymentAuthorizationStatusSuccess);
    }
}
@end
