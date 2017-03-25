/**
 * Titanium Apple Pay
 * Copyright (c) 2015-Present by Hans Knoechel. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiApplepayPaymentButton.h"
#import "TiApplepayPaymentButtonProxy.h"
#import "TiUtils.h"
#import "TiApp.h"

@implementation TiApplepayPaymentButtonProxy

- (TiApplepayPaymentButton *)paymentButton
{
    return (TiApplepayPaymentButton *)self.view;
}

- (void)viewDidAttach
{
    [[self paymentButton] paymentButton];
}

- (NSString *)apiName
{
    return @"Ti.ApplePay.PaymentButton";
}

#pragma mark Public APIs

- (void)setType:(id)value
{
    ENSURE_TYPE(value, NSNumber);
    [self replaceValue:value forKey:@"type" notification:NO];
}

- (void)setStyle:(id)value
{
    ENSURE_TYPE(value, NSNumber);
    [self replaceValue:value forKey:@"style" notification:NO];
}

#pragma mark Layout Helper

- (UIViewAutoresizing)verifyAutoresizing:(UIViewAutoresizing)suggestedResizing
{
    return suggestedResizing & ~(UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth);
}

USE_VIEW_FOR_VERIFY_HEIGHT
USE_VIEW_FOR_VERIFY_WIDTH

- (TiDimension)defaultAutoWidthBehavior:(id)unused
{
    return TiDimensionAutoFill;
}

- (TiDimension)defaultAutoHeightBehavior:(id)unused
{
    return TiDimensionAutoFill;
}

@end
