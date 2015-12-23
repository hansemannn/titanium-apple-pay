/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2015 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
#import "TiProxy.h"
#import <PassKit/PassKit.h>

@interface TiApplepayPaymentAuthorizationCompletionHandlerProxy : TiProxy {}
    
@property(nonatomic,copy) void (^ _Nonnull handler)(PKPaymentAuthorizationStatus);
    
-(void)complete:(id _Nonnull)args;

@end
