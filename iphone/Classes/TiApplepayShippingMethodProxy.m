/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2015 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiApplepayShippingMethodProxy.h"
#import "TiUtils.h"

@implementation TiApplepayShippingMethodProxy

-(PKShippingMethod *)shippingMethod
{
    if (shippingMethod == nil) {
        shippingMethod = [PKShippingMethod new];
    }
    
    return shippingMethod;
}

-(void)setTitle:(id)value
{
    ENSURE_TYPE(value, NSString);
    [[self shippingMethod] setLabel:[TiUtils stringValue:value]];
}

-(void)setIdentifier:(id)value
{
    ENSURE_TYPE(value, NSString);
    [[self shippingMethod] setIdentifier:[TiUtils stringValue:value]];
}

-(void)setDescription:(id)value
{
    ENSURE_TYPE(value, NSString);
    [[self shippingMethod] setDetail:[TiUtils stringValue:value]];
}

-(void)setPrice:(id)value
{
    ENSURE_TYPE(value, NSNumber);
    [[self shippingMethod] setAmount:[NSDecimalNumber decimalNumberWithDecimal:[[TiUtils numberFromObject:value] decimalValue]]];
}

@end
