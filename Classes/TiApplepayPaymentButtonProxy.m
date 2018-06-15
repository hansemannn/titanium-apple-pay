/**
 * Titanium Apple Pay
 * Copyright (c) 2015-Present by Hans Knoechel. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiApplepayPaymentButtonProxy.h"
#import "TiApp.h"
#import "TiApplepayPaymentButton.h"
#import "TiUtils.h"

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

- (void)setType:(NSNumber*)type
{
  [self replaceValue:type forKey:@"type" notification:NO];
}

- (void)setStyle:(NSNumber *)style
{
  [self replaceValue:style forKey:@"style" notification:NO];
}

- (void)setBorderRadius:(NSNumber *)borderRadius
{
#if IS_XCODE_10
  if (![TiUtils isIOSVersionOrGreater:@"12.0"]) {
    DebugLog(@"[ERROR] The borderRadius property is only available in iOS 12 and later.");
    return;
  }

  [[[self paymentButton] paymentButton] setCornerRadius:[TiUtils floatValue:borderRadius]];
#endif
}

#pragma mark Layout Helper

- (UIViewAutoresizing)verifyAutoresizing:(UIViewAutoresizing)suggestedResizing
{
  return suggestedResizing & ~(UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
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
