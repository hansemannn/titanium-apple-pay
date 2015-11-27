/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2015 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiApplepayPaymentButton.h"
#import "TiApplepayPaymentButtonProxy.h"

@implementation TiApplepayPaymentButton

-(TiApplepayPaymentButtonProxy*)paymentButtonProxy
{
    return (TiApplepayPaymentButtonProxy*)[self proxy];
}

-(void)dealloc
{
    [paymentButton removeTarget:self action:@selector(didTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    RELEASE_TO_NIL(paymentButton);
    
    [super dealloc];
}

-(PKPaymentButton*)paymentButton
{
    if (paymentButton == nil) {
        id type = [[self paymentButtonProxy] valueForKey:@"type"];
        id style = [[self paymentButtonProxy] valueForKey:@"style"];
        
        paymentButton = [[PKPaymentButton alloc] initWithPaymentButtonType:[TiUtils intValue:type def:PKPaymentButtonTypePlain] paymentButtonStyle:[TiUtils intValue:style def:PKPaymentButtonStyleWhite]];
        
        [self setFrame:[paymentButton frame]];
        [self addSubview:paymentButton];
        [paymentButton addTarget:self action:@selector(didTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return paymentButton;
}

- (IBAction)didTouchUpInside:(id)sender
{
    if ([[self paymentButtonProxy] _hasListeners:@"click"]) {
        [[self paymentButtonProxy] fireEvent:@"click" withObject:@{@"buttonType": [[self paymentButtonProxy] valueForKey:@"type"]}];
    }
}

-(BOOL)hasTouchableListener
{
    return YES;
}

-(CGFloat)verifyWidth:(CGFloat)suggestedWidth
{
    return [self sizeThatFits:CGSizeZero].width;
}

-(CGFloat)verifyHeight:(CGFloat)suggestedHeight
{
    return [self sizeThatFits:CGSizeZero].height;
}

@end
